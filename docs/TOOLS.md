# Tools and Helpers

This document lists helper tools to enforce commit SHA pinning and ease workflow adoption.

## Resolve `uses:` Pin Script

Path: `scripts/resolve-uses-pin.sh`

Usage:

```
./scripts/resolve-uses-pin.sh <owner>/<repo> .github/workflows/<workflow>.yml <ref>

# Example:
./scripts/resolve-uses-pin.sh lferrarotti74/github-workflows-templates .github/workflows/build-extended.yml v0.1.0
```

Behavior:
- Resolves annotated tags (`tag^{}`), lightweight tags, branches, or raw SHAs to a commit SHA using `git ls-remote`.
- Prints a ready-to-copy pinned `uses:` line.
- Recommends `gh` API commands if resolution fails.

## GitHub Action: Resolve Pin (Template)

Caller workflow example users can add to their repo:

```yaml
name: Resolve uses pin

on:
  workflow_dispatch:
    inputs:
      repo:
        description: 'owner/repo (e.g., lferrarotti74/github-workflows-templates)'
        required: true
      workflow_path:
        description: '.github/workflows/<file>.yml'
        required: true
      ref:
        description: 'Tag, branch, or commit SHA (e.g., v0.1.0 or main)'
        required: true

jobs:
  resolve:
    runs-on: ubuntu-latest
    steps:
      - name: Resolve via git ls-remote
        id: git
        run: |
          set -euo pipefail
          REPO="${{ inputs.repo }}"
          WORKFLOW="${{ inputs.workflow_path }}"
          REF="${{ inputs.ref }}"
          REMOTE="https://github.com/${REPO}.git"

          sha=$(git ls-remote --tags "$REMOTE" "${REF}^{ }" | awk '{print $1}')
          if [ -z "$sha" ]; then
            sha=$(git ls-remote --tags "$REMOTE" "$REF" | awk '{print $1}')
          fi
          if [ -z "$sha" ]; then
            sha=$(git ls-remote --heads "$REMOTE" "$REF" | awk '{print $1}')
          fi
          if [ -z "$sha" ]; then
            echo "Could not resolve ${REF} via git. Try gh API." >&2
            exit 1
          fi
          echo "sha=$sha" >> "$GITHUB_OUTPUT"

      - name: Print pinned uses
        run: |
          echo "Pinned line:"
          echo "uses: ${{ inputs.repo }}/${{ inputs.workflow_path }}@${{ steps.git.outputs.sha }}"
```

---

## Security Scanners Overview

The `build-extended.yml` reusable workflow integrates multiple security tools and produces standardized artifacts for downstream consumption and the build summary.

- Trivy (container vulnerabilities)
  - Runs in `table`, `json`, and `sarif` formats.
  - Artifacts: `trivy-report.txt`, `trivy-report.json`, `trivy-report.sarif`.
  - SARIF is uploaded to GitHub Code Scanning.
  - Summary metrics: counts by severity (critical, high, medium, low).

- Trivy Secrets (secret scanning)
  - Runs in `table` and `json` formats for reliable parsing.
  - Artifacts: `trivy-secrets.txt`, `trivy-secrets.json`.
  - Summary metric: total secret findings. Parser supports both `.Secrets` and `.Findings` JSON structures.

- Syft (SBOM)
  - Generates an SBOM of the image.
  - Artifact: `sbom.json`.

- Grype (vulnerability scanning using SBOM/data)
  - Runs in `json` format.
  - Artifact: `grype-report.json`.
  - Summary metrics: counts by severity (Critical, High, Medium, Low).

- OSV Scanner
  - Scans the built image for vulnerabilities using OSV database.
  - Artifact: `osv-report.json`.
  - Summary metric: total OSV vulnerabilities across results.

### Build Summary Integration

The workflow computes and exposes metrics via the `security-scan` job and renders them in the final build summary:

- Trivy CVEs: `critical`, `high`, `medium`, `low`
- Trivy Secrets: `findings count`
- Grype CVEs: `Critical`, `High`, `Medium`, `Low`
- OSV: `total vulnerabilities`

Artifacts are uploaded under the `security-reports` artifact bundle for auditing and offline analysis.