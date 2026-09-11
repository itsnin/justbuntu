#!/bin/bash
# Set common git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true

# Set the identity and optional HTTPS credentials collected with the other
# first-run choices. The secret may be a Git password or personal access token.
if [[ -n "${JUSTBUNTU_GIT_USER_NAME:-}" ]]; then
  git config --global user.name "$JUSTBUNTU_GIT_USER_NAME"
fi

if [[ -n "${JUSTBUNTU_GIT_USER_EMAIL:-}" ]]; then
  git config --global user.email "$JUSTBUNTU_GIT_USER_EMAIL"
fi

if [[ -n "${JUSTBUNTU_GIT_CREDENTIAL_USERNAME:-}" &&
      -n "${JUSTBUNTU_GIT_CREDENTIAL_SECRET:-}" ]]; then
  if ! git config --global --get-all credential.helper >/dev/null 2>&1; then
    git config --global credential.helper 'cache --timeout=28800'
  fi
  if ! printf 'protocol=https\nhost=github.com\nusername=%s\npassword=%s\n\n' \
    "$JUSTBUNTU_GIT_CREDENTIAL_USERNAME" \
    "$JUSTBUNTU_GIT_CREDENTIAL_SECRET" | git credential approve; then
    echo "Git credential setup failed (continuing)"
  fi
fi
