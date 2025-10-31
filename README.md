# GitHub Workflows Templates

Welcome to **`github-workflows-templates`** — a centralized repository for **reusable GitHub Actions workflows**, designed to simplify CI/CD across multiple repositories.  
This repo is optimized for **Docker multi-architecture builds**, automatic version tagging, and flexible workflow reuse.

---

## 📦 Available Workflows

| Workflow | Description | Usage |
|-----------|--------------|--------|
| **build-extended.yml** | Reusable Docker build workflow with multi-arch support, auto-version detection, and dual registry push (Docker Hub + optional GHCR). | `uses: lferrarotti74/github-workflows-templates/.github/workflows/build-extended.yml@main` |

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
    A[Caller Workflow (.yml) in repo] --> B[Reusable Workflow: build-extended.yml]
    B --> C[Optional .env File in repo<br/>e.g., *_VERSION=1.2.0]
    B --> D[Repository Variables & Secrets<br/>IMAGE_ARCHS, ENABLE_PUSH, DOCKERHUB_*]
    B --> E[Docker Buildx: Multi-Arch Build]
    E --> F[Push to Docker Hub & GHCR]
    F --> G[Tags: latest + version]

    classDef repo fill:#f9f,stroke:#333,stroke-width:1px;
    classDef workflow fill:#bbf,stroke:#333,stroke-width:1px;
    classDef docker fill:#bfb,stroke:#333,stroke-width:1px;
    classDef registry fill:#ffb,stroke:#333,stroke-width:1px;
    class A,C,D workflow;
    class B workflow;
    class E docker;
    class F,G registry;
