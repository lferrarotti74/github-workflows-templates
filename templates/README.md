# Workflow Templates: Triggers and Usage

This folder documents how to call the reusable workflows in this repository, including recommended triggers, required permissions, and copy‑paste caller examples.

## Documentation

- Triggers and permissions overview: `docs/TRIGGERS.md`
- Variables and secrets reference: `docs/VARIABLES.md`
- Migration guide to reusable workflows: `docs/MIGRATION_GUIDE.md`
- Create Release workflow usage: `docs/create-release.md`

## Docker Scout (Reusable)

- Recommended trigger: `pull_request` so the job can comment CVEs and recommendations directly on PRs.
- Minimal permissions:
  - `contents: read`
  - `pull-requests: write` (enables commenting)
- Optional:
  - Remove `packages: write` unless you also scan/publish to GHCR.
  - Add a `schedule` (e.g., nightly) if you want periodic scans; scheduled runs won’t write PR comments.

Caller example:

```
name: Security Scan (Docker Scout)

on:
  pull_request:
    branches: [ main ]
    paths-ignore:
      - 'README.md'
      - 'LICENSE'

permissions:
  contents: read
  pull-requests: write

jobs:
  scout:
    uses: lferrarotti74/github-workflows-templates/.github/workflows/docker-scout.yml@<ref>
    with:
      image_name: lferrarotti74/speedtest-ookla
      compare_tag: latest
      env_file_path: env/.env           # optional; use if your .env isn’t at repo root
      version_var_name: SPEEDTEST_VERSION  # optional; match your .env key name
    secrets:
      DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
      DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
```

Notes:
- Ensure `lferrarotti74/speedtest-ookla:<compare_tag>` exists (e.g., `latest`), or use a tag you publish (like `main` or release tags).
- The workflow only passes `VERSION` as a build arg when a value is found in `.env` via `version_var_name`. If your Dockerfile requires `ARG VERSION` with no default, ensure `.env` provides it or add a default in the Dockerfile.
- Pin `uses:` to a commit SHA or a version tag (`@vX.Y.Z`) for reproducibility.

## Sync Main to Dev (Reusable)

- Recommended triggers:
  - `workflow_dispatch` for manual syncs.
  - `schedule` (cron) for automated periodic syncs.
  - Optional: `push` on `main` for immediate sync after merges (use concurrency to avoid overlap).
- Required permissions:
  - `contents: write` (needed to push commits).
- Repository setting:
  - In repo settings → Actions → Workflow permissions, set “Read and write permissions” for `GITHUB_TOKEN` or use a PAT if required.

Caller example (manual + scheduled):

```
name: Sync main → dev

on:
  workflow_dispatch:
  schedule:
    - cron: '0 3 * * *'  # daily at 03:00 UTC

permissions:
  contents: write

concurrency:
  group: sync-main-to-dev
  cancel-in-progress: true

jobs:
  sync:
    uses: lferrarotti74/github-workflows-templates/.github/workflows/sync-main-to-dev.yml@<ref>
    with:
      source_branch: main
      target_branch: dev
```

Variant (auto after push to main):

```
on:
  push:
    branches: [ main ]

permissions:
  contents: write

jobs:
  sync:
    uses: lferrarotti74/github-workflows-templates/.github/workflows/sync-main-to-dev.yml@<ref>
    with:
      source_branch: main
      target_branch: dev
```

Operational tips:
- Use `concurrency` to avoid overlapping runs.
- If `dev` is protected, enable “Allow GitHub Actions to push to protected branches” or configure appropriate bypass rules.
- The workflow pushes only when `main` is not already contained in `dev` (idempotent).

## Pinning Strategy

- Prefer pinning to a commit SHA (immutable) or to a released tag (e.g., `@v0.1.0`). Avoid floating refs for production.

## Image Naming (Docker Hub)

- Set `image_name` to your Docker Hub repo in `namespace/image` form, e.g., `lferrarotti74/speedtest-ookla`.