# Triggers and Permissions

This document outlines recommended GitHub Actions triggers and minimal permissions for the reusable workflows in this repository. Use these as caller-side guidance when referencing workflows via `uses: lferrarotti74/github-workflows-templates/.github/workflows/<file>@<ref>`.

## Docker Scout

- Recommended triggers:
  - `pull_request` to analyze images and write summary comments directly on PRs.
  - Optional `schedule` (cron) for periodic scans; note scheduled runs do not comment on PRs.
- Minimal permissions:
  - `contents: read`
  - `pull-requests: write` (required to post PR comments)
- Optional permissions:
  - Remove `packages: write` unless also scanning/publishing GHCR.
- Notes:
  - Pass `image_name` (Docker Hub repo, e.g., `lferrarotti74/speedtest-ookla`) and a valid `compare_tag` (e.g., `latest`).
  - If using an `.env` file, set `env_file_path` (e.g., `env/.env`) and `version_var_name` (e.g., `SPEEDTEST_VERSION`). The reusable workflow maps that to `ARG VERSION` in your Dockerfile.

Caller skeleton:

```yaml
on:
  pull_request:
    branches: [ main ]
permissions:
  contents: read
  pull-requests: write

jobs:
  scout:
    uses: lferrarotti74/github-workflows-templates/.github/workflows/docker-scout.yml@<commit-sha>
    with:
      image_name: lferrarotti74/speedtest-ookla
      compare_tag: latest
      env_file_path: env/.env
      version_var_name: SPEEDTEST_VERSION
    secrets:
      DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
      DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
```

## Sync Main to Dev

- Recommended triggers:
  - `workflow_dispatch` for manual operations.
  - `schedule` (cron) for periodic sync.
  - Optional `push` on `main` for immediate sync after merges.
- Required permissions:
  - `contents: write` (needed to push commits to target branch)
- Repository settings:
  - Enable “Read and write permissions” for `GITHUB_TOKEN` in repo settings, or use a PAT if required.
- Best practice:
  - Use `concurrency` to avoid overlapping sync runs.

Caller skeleton:

```yaml
on:
  workflow_dispatch:
  schedule:
    - cron: '0 3 * * *'
permissions:
  contents: write
concurrency:
  group: sync-main-to-dev
  cancel-in-progress: true

jobs:
  sync:
    uses: lferrarotti74/github-workflows-templates/.github/workflows/sync-main-to-dev.yml@<commit-sha>
    with:
      source_branch: main
      target_branch: dev
```

## Build Extended (Docker)

- Recommended triggers:
  - `push` to `main` for continuous builds and publishing.
  - `workflow_dispatch` for manual builds.
  - Optional `pull_request` with `enable_push: false` for build validation without publishing.
- Minimal permissions:
  - `contents: read`
- Optional permissions:
  - `packages: write` only if pushing to GHCR in addition to Docker Hub.
- Notes:
  - Provide Docker Hub secrets: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.
  - Configure `arch_list`, `enable_push`, and optional GHCR settings as needed.

Caller skeleton:

```yaml
on:
  push:
    branches: [ main ]
  workflow_dispatch:
permissions:
  contents: read

jobs:
  build:
    uses: lferrarotti74/github-workflows-templates/.github/workflows/build-extended.yml@<commit-sha>
    with:
      image_name: lferrarotti74/speedtest-ookla
      arch_list: linux/amd64,linux/arm64
      enable_push: true
    secrets:
      DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
      DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
```

## Create Release

- Recommended triggers:
  - `workflow_dispatch` to create releases manually.
  - `push` on tags (e.g., `v*`) to automate release creation on version tags.
- Minimal permissions:
  - `contents: write` (required to create releases)
- Notes:
  - Ensure semantic versioning and tag format alignment (e.g., `v1.2.3`).

Caller skeleton:

```yaml
on:
  workflow_dispatch:
  push:
    tags:
      - 'v*'
permissions:
  contents: write

jobs:
  release:
    uses: lferrarotti74/github-workflows-templates/.github/workflows/create-release.yml@<commit-sha>
```

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