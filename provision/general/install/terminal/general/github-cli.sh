#!/bin/bash
# Install GitHub CLI (gh) from Ubuntu repositories
sudo apt install -y gh || echo "github cli install failed (continuing)"

if [[ "${JUSTBUNTU_GITHUB_AUTH:-false}" != "true" ]]; then
  return 0
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is unavailable; skipping GitHub authentication (continuing)"
  return 0
fi

if gh auth status --hostname github.com >/dev/null 2>&1; then
  echo "GitHub CLI is already authenticated"
  return 0
fi

echo "==> Starting GitHub authentication"
if gh auth login --hostname github.com --web --git-protocol https; then
  gh auth setup-git --hostname github.com || echo "Git credential setup failed (continuing)"
else
  echo "GitHub authentication skipped or failed (continuing)"
fi
