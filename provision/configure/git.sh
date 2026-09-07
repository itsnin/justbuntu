#!/bin/bash
# Set common git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true

# Set git identity. Check environment variables first, then prompt.
# Empty input (just pressing Enter) skips — nothing is forced.
if [[ -n "${JUSTBUNTU_GIT_USER_NAME:-}" ]]; then
  git config --global user.name "$JUSTBUNTU_GIT_USER_NAME"
else
  GIT_NAME=$(gum input --placeholder "Git user name (leave empty to skip)" --header "Git identity" 2>/dev/null || true)
  if [[ -n "$GIT_NAME" ]]; then
    git config --global user.name "$GIT_NAME"
  fi
fi

if [[ -n "${JUSTBUNTU_GIT_USER_EMAIL:-}" ]]; then
  git config --global user.email "$JUSTBUNTU_GIT_USER_EMAIL"
else
  GIT_EMAIL=$(gum input --placeholder "Git user email (leave empty to skip)" --header "Git identity" 2>/dev/null || true)
  if [[ -n "$GIT_EMAIL" ]]; then
    git config --global user.email "$GIT_EMAIL"
  fi
fi
