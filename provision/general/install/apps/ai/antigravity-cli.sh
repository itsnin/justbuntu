#!/bin/bash
# Install Google Antigravity CLI (agy)
# Requires Google account authentication after installation.
# Download to temp file first, then pipe "n" to any interactive prompts.
TMP_INSTALL=$(mktemp)
if curl -fsSL --retry 3 --retry-delay 5 https://antigravity.google/cli/install.sh -o "$TMP_INSTALL"; then
  if echo n | script -q -c "bash $TMP_INSTALL" /dev/null; then
    echo "antigravity cli installed. run 'agy' to authenticate and start."
  fi
fi
rm -f "$TMP_INSTALL"
