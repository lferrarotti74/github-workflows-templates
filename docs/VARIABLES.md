# Variables and Secrets for GitHub Workflows Templates

This file documents all the **inputs, variables, secrets, and environment expectations** for the reusable workflows in this repository.

## 1. Workflow Inputs (`workflow_call`)

All reusable workflows accept inputs from caller workflows.

| Input Name    | Description                                                                     | Required | Default                   |
| ------------- | ------------------------------------------------------------------------------- | -------- | ------------------------- |
| `image_name`  | The Docker image name (e.g., `speedtest` or `myapp`).                           | Yes      | —                         |
| `arch_list`   | Comma-separated list of target architectures (e.g., `linux/amd64,linux/arm64`). | No       | `linux/amd64,linux/arm64` |
| `enable_push` | Whether to push the built images to Docker Hub/GHCR.                            | No       | `true`                    |

## 2. Repository Secrets

All secrets must be configured in **Settings → Secrets and Variables → Actions** of each repository using the workflow.

| Secret Name               | Description                                              | Required |
| ------------------------- | -------------------------------------------------------- | -------- |
| `DOCKERHUB_USERNAME`      | Docker Hub username for login/push                       | Yes      |
| `DOCKERHUB_TOKEN`         | Docker Hub personal access token                         | Yes      |
| `GHCR_TOKEN` *(optional)* | Personal Access Token for GHCR if separate push required | Optional |

> Notes:
>
> * GHCR push is optional. If your workflow does not need it, you can skip GHCR_TOKEN.

## 3. Repository Variables

Variables can be defined under **Settings → Secrets and Variables → Actions → Variables** to configure workflows per repo.

| Variable Name | Description                              | Example Value             |
| ------------- | ---------------------------------------- | ------------------------- |
| `IMAGE_ARCHS` | List of architectures for Buildx builds. | `linux/amd64,linux/arm64` |
| `ENABLE_PUSH` | Whether the workflow should push images. | `true`                    |

## 4. `.env` Version File

The workflow can optionally read a `.env` file from the repo:

* **Location**: `env/.env`
* **Format**: `<PROJECT>_VERSION=<version>`
* **Example**:

```env
SPEEDTEST_VERSION=1.2.0
```

**Behavior:**

1. Workflow detects the first `_VERSION` variable in `.env`.
2. If `.env` is missing or variable not found, the workflow defaults to the **short Git commit SHA** for tagging.
3. Detected version is automatically used to tag images alongside `latest`.

## 5. Environment Variables Set by Workflow

During execution, reusable workflows will set the following environment variables:

| Variable Name    | Description                                                              |
| ---------------- | ------------------------------------------------------------------------ |
| `REGISTRY_IMAGE` | Full Docker Hub image name: `${DOCKERHUB_USERNAME}/${IMAGE_NAME}`        |
| `GHCR_IMAGE`     | Full GHCR image name: `ghcr.io/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME}` |
| `VERSION`        | Version detected from `.env` or Git SHA fallback                         |
| `ARCH_LIST`      | List of architectures for Buildx                                         |
| `PUSH_ENABLED`   | Whether image push is enabled (`true` / `false`)                         |

---

This file should be kept up-to-date as new reusable workflows are added or modified.

---

## Pinning and Security

For security and compliance, pin reusable workflows with a **commit SHA** instead of floating refs like `@main`.

### Finding the Commit SHA

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
