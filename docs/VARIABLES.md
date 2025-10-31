# Variables and Secrets for GitHub Workflows Templates

This file documents all the **inputs, variables, secrets, and environment expectations** for the reusable workflows in this repository.

---

## 1. Workflow Inputs (`workflow_call`)

All reusable workflows accept inputs from caller workflows.

| Input Name    | Description                                                                 | Required | Default                          |
|---------------|-----------------------------------------------------------------------------|----------|----------------------------------|
| `image_name`  | The Docker image name (e.g., `speedtest` or `myapp`).                       | Yes      | —                                |
| `arch_list`   | Comma-separated list of target architectures (e.g., `linux/amd64,linux/arm64`). | No       | `linux/amd64,linux/arm64`       |
| `enable_push` | Whether to push the built images to Docker Hub/GHCR.                        | No       | `true`                           |

---

## 2. Repository Secrets

All secrets must be configured in **Settings → Secrets and Variables → Actions** of each repository using the workflow.

| Secret Name           | Description                             | Required |
|-----------------------|-----------------------------------------|----------|
| `DOCKERHUB_USERNAME`  | Docker Hub username for login/push       | Yes      |
| `DOCKERHUB_TOKEN`     | Docker Hub personal access token         | Yes      |
| `GHCR_TOKEN` *(optional)* | Personal Access Token for GHCR if separate push required | Optional |

> Notes:
> - GHCR push is optional. If your workflow does not need it, you can skip GHCR_TOKEN.

---

## 3. Repository Variables

Variables can be defined under **Settings → Secrets and Variables → Actions → Variables** to configure workflows per repo.

| Variable Name     | Description                                                             | Example Value                     |
|------------------|-------------------------------------------------------------------------|----------------------------------|
| `IMAGE_ARCHS`     | List of architectures for Buildx builds.                                 | `linux/amd64,linux/arm64`       |
| `ENABLE_PUSH`     | Whether the workflow should push images.                                 | `true`                           |

---

## 4. `.env` Version File

The workflow can optionally read a `.env` file from the repo:

- **Location**: `env/.env`
- **Format**: `<PROJECT>_VERSION=<version>`
- **Example**:
  ```env
  SPEEDTEST_VERSION=1.2.0

