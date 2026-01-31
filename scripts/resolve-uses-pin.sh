#!/usr/bin/env bash
# Resolve a tag or branch to a commit SHA and print a pinned `uses:` line.
# Usage: ./scripts/resolve-uses-pin.sh <owner>/<repo> <workflow_path> <ref>
# Example: ./scripts/resolve-uses-pin.sh lferrarotti74/github-workflows-templates .github/workflows/build-extended.yml v0.1.0

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <owner>/<repo> <workflow_path> <ref>" >&2
  exit 1
fi

REPO="$1"
WORKFLOW_PATH="$2"
REF="$3"
REMOTE_URL="https://github.com/${REPO}.git"

resolve_sha_via_git() {
  local ref="$1"
  local sha=""

  # Try annotated tag dereference first (tag^{})
  sha=$(git ls-remote --tags "${REMOTE_URL}" "${ref}^{ }" 2>/dev/null | awk '{print $1}')
  if [[ -n "${sha}" ]]; then
    echo "${sha}"
    return 0
  fi

  # Try lightweight tag
  sha=$(git ls-remote --tags "${REMOTE_URL}" "${ref}" 2>/dev/null | awk '{print $1}')
  if [[ -n "${sha}" ]]; then
    echo "${sha}"
    return 0
  fi

  # Try branch (heads)
  sha=$(git ls-remote --heads "${REMOTE_URL}" "${ref}" 2>/dev/null | awk '{print $1}')
  if [[ -n "${sha}" ]]; then
    echo "${sha}"
    return 0
  fi

  # If REF looks like a SHA already, accept it
  if [[ "${ref}" =~ ^[0-9a-fA-F]{40}$ ]]; then
    echo "${ref}"
    return 0
  fi

  return 1
}

SHA="$(resolve_sha_via_git "${REF}")" || {
  echo "Error: Could not resolve ref '${REF}' in ${REPO} via git ls-remote." >&2
  echo "Try using gh CLI:" >&2
  echo "  gh api repos/${REPO}/git/refs/heads/${REF} --jq .object.sha" >&2
  echo "  TAG_OBJ_SHA=\$(gh api repos/${REPO}/git/refs/tags/${REF} --jq .object.sha)" >&2
  echo "  gh api repos/${REPO}/git/tags/\$TAG_OBJ_SHA --jq .object.sha" >&2
  exit 2
}

echo "uses: ${REPO}/${WORKFLOW_PATH}@${SHA}"