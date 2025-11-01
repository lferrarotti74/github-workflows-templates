# Reusable Workflow — Create GitHub Release

This reusable workflow automates **tag creation**, **release generation**, and **asset packaging** for any repository. It ensures safe versioning with validation, optional dry-run support, and compatibility with submodules.

---

## File Location

```
.github/workflows/create-release.yml
```

This workflow lives inside the [`lferrarotti74/github-workflows-templates`](https://github.com/lferrarotti74/github-workflows-templates) repository and can be called from other repositories.

---

## How to Use It

In your target repository (for example, `SpeedTest-Ookla`), create a new workflow file:

```yaml
# .github/workflows/create-release.yml
name: Create Release

on:
  workflow_dispatch:
    inputs:
      tag:
        description: 'Tag to create (e.g. v6.12-r0, v1.2.0)'
        required: true
      dry_run:
        description: 'Dry run mode (no release creation)'
        required: false
        type: boolean
        default: true
      force:
        description: 'Force overwrite existing tag'
        required: false
        type: boolean
        default: false

jobs:
  call-reusable:
    uses: lferrarotti74/github-workflows-templates/.github/workflows/create-release.yml@main
    with:
      tag: ${{ inputs.tag }}
      dry_run: ${{ inputs.dry_run }}
      force: ${{ inputs.force }}
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Then trigger it manually from the **Actions** tab in your repo.

---

## Inputs

| Input     | Type    | Default | Required | Description                                                   |
| --------- | ------- | ------- | -------- | ------------------------------------------------------------- |
| `tag`     | string  | —       | ✅        | The tag to create, e.g. `v1.2.0`, `v6.12-r0`, `v1.0.0-beta.1` |
| `dry_run` | boolean | `true`  | ❌        | When true, simulates the release without creating it          |
| `force`   | boolean | `false` | ❌        | Overwrites an existing tag if already present                 |

---

## Secrets

| Secret         | Required | Description                                                          |
| -------------- | -------- | -------------------------------------------------------------------- |
| `GITHUB_TOKEN` | ✅        | Default GitHub Actions token, used for tag push and release creation |

> This token is automatically available in all repositories — no manual configuration is required.

---

## Features

* ✅ Validates tag format before release (supports semver, release suffix, pre-release)
* ✅ Dry-run support (no actual tag or release created)
* ✅ Force overwrite option for existing tags
* ✅ Generates both `.tar.gz` and `.zip` archives
* ✅ Compatible with repositories using submodules
* ✅ Fully pinned dependencies for stability

---

## Example Usage (Dry Run)

To simulate the release process without pushing a tag:

```
Run workflow → tag = v1.2.0 → dry_run = true
```

Output example:

```
🛠 Dry-run mode — no tag/release/archives creation.
Would create release for tag: v1.2.0
```

---

## Example Usage (Real Release)

To actually create the release:

```
Run workflow → tag = v1.2.0 → dry_run = false
```

Output example:

```
✅ Tag format validated: v1.2.0
🏷 Created tag and GitHub Release successfully.
📦 Uploaded release/v1.2.0.{zip,tar.gz}
```

---

## Version & Maintenance

* Template repo: **lferrarotti74/github-workflows-templates**
* Template path: `.github/workflows/create-release.yml`
* Latest tag: `main`
* Maintainer: **Luca Ferrarotti**

---

## Folder Structure (Recommended)

```
github-workflows-templates/
├─ .github/
│  └─ workflows/
│     └─ create-release.yml
└─ docs/
   └─ create-release.md
```

---

## Notes

* All actions are pinned to a specific commit SHA for security and reproducibility.
* Compatible with **GitHub Free**, **Pro**, and **Team** plans.
* This template can be extended later to publish Docker image releases or multi-arch tags.
