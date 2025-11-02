# Migration Guide: Moving Local Workflows to Reusable Workflows

This guide helps you migrate existing per-repo GitHub workflows into the centralized reusable workflow template.

## 1. Preparation

* Ensure you have access to the `github-workflows-templates` repository.
* Identify all repositories that will migrate to reusable workflows.
* Verify each repo has a valid Dockerfile and existing workflow files.
* Backup existing `.github/workflows/*.yml` files.

## 2. Backup Existing Workflows

* Create a backup folder in your repo:

```bash
mkdir backup-workflows
cp .github/workflows/*.yml backup-workflows/
```

* Note which workflows handle builds, tests, releases, or notifications.

## 3. Set Repository Secrets and Variables

**Secrets:**

* `DOCKERHUB_USERNAME`
* `DOCKERHUB_TOKEN`
* Optional: `GHCR_TOKEN`

**Variables:**

* `IMAGE_ARCHS` → e.g., `linux/amd64,linux/arm64`
* `ENABLE_PUSH` → `true` or `false`

> These are defined in **Settings → Secrets and Variables → Actions**.

## 4. Optional: Create `.env` for Versioning

* File path: `env/.env`
* Format: `<PROJECT>_VERSION=<version>`
* Example:

```env
SPEEDTEST_VERSION=1.2.0
```

* Workflow detects the first `_VERSION` variable.
* If missing, workflow uses the short Git commit SHA as fallback.

## 5. Create Caller Workflow

* Delete or rename old workflow files (e.g., `build.yml`).
* Create `.github/workflows/build.yml`:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: ["main"]
  workflow_dispatch:

jobs:
  docker-build:
    uses: lferrarotti74/github-workflows-templates/.github/workflows/build-extended.yml@<commit-sha>
    with:
      image_name: <your-image-name>
      arch_list: ${{ vars.IMAGE_ARCHS }}
      enable_push: ${{ vars.ENABLE_PUSH }}
      enable_security_scan: true
    secrets:
      DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
      DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
```

> Replace `<your-image-name>` with your Docker image name.
>
> Pinning policy: Use a **commit SHA** for `@<commit-sha>` to comply with security scanners (e.g., SonarQube). Avoid floating refs like `@main` or version tags in production.

> Security scan: When `enable_security_scan` is true, the workflow runs Trivy (table/json/SARIF), Grype (json), Syft SBOM (json), and OSV Scanner (json). Artifacts are uploaded as `security-reports`, and the final build summary includes CVE and secret counts.

## 6. Validate Workflow

1. Commit and push:

```bash
git add .github/workflows/build.yml env/.env
git commit -m "Migrate to reusable workflow"
git push
```

2. Trigger workflow manually via **Actions → Run workflow**.
3. Check logs:

   * Version detection works (`.env` or SHA fallback)
   * Multi-arch images build
   * Images pushed to Docker Hub and optionally GHCR
   * Security scan finishes and uploads artifacts (`security-reports`)
   * Build summary displays Trivy/Grype/OSV counts and secret findings

## 7. Optional: Repeat for Other Workflows

* Testing, linting, release, or notification workflows can also be migrated similarly using separate reusable workflow templates.

## 8. Cleanup & Documentation

* Remove old workflow files after validation.
* Update README to indicate the repo now uses reusable workflows.
* Document any special per-repo variables or environment requirements.

## Notes

* Caller workflows remain lightweight.
* All logic is centralized in `github-workflows-templates`.
* Workflows are flexible and safe to extend with additional architectures or registries.
* When enabled, security scans run post-build; the `build-summary` job depends on `security-scan` via `needs` to render metrics.

---

## Finding the Commit SHA

```
Use one of these methods to obtain a commit SHA for pinning:

1) Current repo (your local checkout):
   git rev-parse HEAD

2) Another repo by tag (resolves annotated tags to the commit):
   # Replace <owner>/<repo> and <tag>
   git ls-remote https://github.com/<owner>/<repo>.git <tag>^{}
   # Example:
   git ls-remote https://github.com/lferrarotti74/github-workflows-templates.git v0.1.0^{}

3) Another repo by branch:
   # Replace <owner>/<repo> and <branch>
   git ls-remote --heads https://github.com/<owner>/<repo>.git <branch>
   # Example:
   git ls-remote --heads https://github.com/lferrarotti74/github-workflows-templates.git main

4) GitHub CLI (if you use gh):
   # Branch:
   gh api repos/<owner>/<repo>/git/refs/heads/<branch> --jq .object.sha
   # Tag (handles annotated tags — two-step):
   TAG_OBJ_SHA=$(gh api repos/<owner>/<repo>/git/refs/tags/<tag> --jq .object.sha)
   gh api repos/<owner>/<repo>/git/tags/$TAG_OBJ_SHA --jq .object.sha

Once you have the SHA, pin your reusable workflow:
uses: <owner>/<repo>/.github/workflows/<workflow>@<commit-sha>
```
