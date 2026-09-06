#!/bin/bash
# Set common git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
# Set git identity from environment variables if provided. Env var pattern.
# Set JUSTBUNTU_GIT_USER_NAME and JUSTBUNTU_GIT_USER_EMAIL before running to auto-configure.
if [[ -n "${JUSTBUNTU_GIT_USER_NAME:-}" ]]; then
  git config --global user.name "$JUSTBUNTU_GIT_USER_NAME"
fi
if [[ -n "${JUSTBUNTU_GIT_USER_EMAIL:-}" ]]; then
  git config --global user.email "$JUSTBUNTU_GIT_USER_EMAIL"
fi
