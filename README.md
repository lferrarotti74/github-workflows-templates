# GitHub Workflows Templates

Welcome to **`github-workflows-templates`** — a centralized repository for **reusable GitHub Actions workflows**, designed to simplify CI/CD across multiple repositories.  
This repo is optimized for **Docker multi-architecture builds**, automatic version tagging, and flexible workflow reuse.

---

## 📚 Further Reading

- Triggers and permissions for reusable workflows: `docs/TRIGGERS.md`
- Variables and secrets reference: `docs/VARIABLES.md`
- Migration guide to reusable workflows: `docs/MIGRATION_GUIDE.md`
- Create Release workflow usage: `docs/create-release.md`

---

## 📦 Available Workflows

| Workflow | Description | Usage |
|-----------|--------------|--------|
| **build-extended.yml** | Reusable Docker build with multi-arch support, auto-version detection, and dual registry push (Docker Hub + optional GHCR). | `uses: lferrarotti74/github-workflows-templates/.github/workflows/build-extended.yml@main` |
| **docker-scout.yml** | Docker image analysis using Docker Scout; summarizes CVEs and recommendations, ideal for PR commenting. | `uses: lferrarotti74/github-workflows-templates/.github/workflows/docker-scout.yml@main` |
| **sync-main-to-dev.yml** | Branch synchronization that merges `main` into `dev` when needed; supports manual and scheduled runs. | `uses: lferrarotti74/github-workflows-templates/.github/workflows/sync-main-to-dev.yml@main` |
| **create-release.yml** | Automated tag validation and GitHub Release creation with optional dry-run and assets packaging. | `uses: lferrarotti74/github-workflows-templates/.github/workflows/create-release.yml@main` |
| **dependabot-reviewer.yml** | Dependabot PR reviewer/manager: auto-labels, enforces policies, and streamlines update workflows. | `uses: lferrarotti74/github-workflows-templates/.github/workflows/dependabot-reviewer.yml@main` |

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
    uses: lferrarotti74/github-workflows-templates/.github/workflows/build-extended.yml@main
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

