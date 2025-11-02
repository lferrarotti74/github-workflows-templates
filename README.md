# GitHub Workflows Templates

Welcome to **`github-workflows-templates`** — a centralized repository for **reusable GitHub Actions workflows**, designed to simplify CI/CD across multiple repositories.  
This repo is optimized for **Docker multi-architecture builds**, automatic version tagging, and flexible workflow reuse.

---

## 📚 Further Reading

- Triggers and permissions for reusable workflows: `docs/TRIGGERS.md`
- Variables and secrets reference: `docs/VARIABLES.md`
- Migration guide to reusable workflows: `docs/MIGRATION_GUIDE.md`
- Create Release workflow usage: `docs/create-release.md`
- Tools and helpers (scripts and action template): `docs/TOOLS.md`

### Pinning Policy

- For security and compliance (e.g., SonarQube), pin reusable workflows with a **commit SHA**:
  - Example: `uses: lferrarotti74/github-workflows-templates/.github/workflows/build-extended.yml@<commit-sha>`
  - Avoid floating refs like `@main` or version tags for production pipelines.

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

---

## 📦 Available Workflows

| Workflow | Description | Usage |
|-----------|--------------|--------|
| **build-extended.yml** | Reusable Docker build with multi-arch support, auto-version detection, and dual registry push (Docker Hub + optional GHCR). | `uses: lferrarotti74/github-workflows-templates/.github/workflows/build-extended.yml@<commit-sha>` |
| **docker-scout.yml** | Docker image analysis using Docker Scout; summarizes CVEs and recommendations, ideal for PR commenting. | `uses: lferrarotti74/github-workflows-templates/.github/workflows/docker-scout.yml@<commit-sha>` |
| **sync-main-to-dev.yml** | Branch synchronization that merges `main` into `dev` when needed; supports manual and scheduled runs. | `uses: lferrarotti74/github-workflows-templates/.github/workflows/sync-main-to-dev.yml@<commit-sha>` |
| **create-release.yml** | Automated tag validation and GitHub Release creation with optional dry-run and assets packaging. | `uses: lferrarotti74/github-workflows-templates/.github/workflows/create-release.yml@<commit-sha>` |
| **dependabot-reviewer.yml** | Dependabot PR reviewer/manager: auto-labels, enforces policies, and streamlines update workflows. | `uses: lferrarotti74/github-workflows-templates/.github/workflows/dependabot-reviewer.yml@<commit-sha>` |

---

## 🔧 Example Usage

Create a lightweight caller workflow in your repository:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  docker-build:
    uses: lferrarotti74/github-workflows-templates/.github/workflows/build-extended.yml@<commit-sha>
    with:
      image_name: myapp
      arch_list: linux/amd64,linux/arm64
      enable_push: true
    secrets:
      DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
      DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
```

---

## 🖼 Workflow Overview

```mermaid
flowchart TD
    A["Caller Workflow (.yml) in repo"] --> B["Reusable Workflow: build-extended.yml"]
    B --> C["Optional .env File in repo (e.g., *_VERSION=1.2.0)"]
    B --> D["Repository Variables & Secrets: IMAGE_ARCHS, ENABLE_PUSH, DOCKERHUB_*"]
    B --> E["Docker Buildx: Multi-Arch Build"]
    E --> F["Push to Docker Hub & GHCR"]
    F --> G["Tags: latest + version"]

    classDef repo fill:#f9f,stroke:#333,stroke-width:1px;
    classDef workflow fill:#bbf,stroke:#333,stroke-width:1px;
    classDef docker fill:#bfb,stroke:#333,stroke-width:1px;
    classDef registry fill:#ffb,stroke:#333,stroke-width:1px;

    class A,C,D workflow;
    class B workflow;
    class E docker;
    class F,G registry;

## 🔒 Security Scan (Trivy + Grype + OSV)

The `build-extended.yml` workflow includes an optional security-scan job that runs after a successful image build.

- Scanners
  - Trivy: image CVE scan in table (`trivy-report.txt`) and SARIF (`trivy-report.sarif` uploaded to Code Scanning)
  - Trivy Secrets: secret scan (`trivy-secrets.txt` + JSON `trivy-secrets.json`)
  - Syft: SBOM generation (`sbom.json`)
  - Grype: image CVE scan (`grype-report.json`)
  - OSV: image vulnerability scan (`osv-report.json`)

- Artifacts (`security-reports`)
  - `trivy-report.txt`, `trivy-report.sarif`, `trivy-report.json`
  - `trivy-secrets.txt`, `trivy-secrets.json`
  - `sbom.json`, `grype-report.json`, `osv-report.json`

- Build Summary Metrics
  - Trivy CVEs: `critical`, `high`, `medium`, `low`
  - Trivy Secrets: findings count
  - Grype CVEs: `Critical`, `High`, `Medium`, `Low`
  - OSV: total vulnerabilities

- Job Dependencies (`needs`)
  - `security-scan` needs `build` (ensures the image exists before scanning)
  - `build-summary` needs `check-base-image`, `build`, `security-scan` (prints results and metrics)

Enable with caller inputs: `enable_security_scan: true`. Ensure `security-events: write` permission for SARIF upload.
