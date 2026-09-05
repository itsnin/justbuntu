#!/bin/bash
# Install Claude Code CLI (Anthropic)
# Requires browser authentication after installation.
# Download to temp file first, then pipe "n" to any interactive prompts.
TMP_INSTALL=$(mktemp)
if curl -fsSL --retry 3 --retry-delay 5 https://claude.ai/install.sh -o "$TMP_INSTALL"; then
  if yes n | bash "$TMP_INSTALL"; then
    echo "claude code cli installed. run 'claude' to authenticate and start."
  fi
fi
rm -f "$TMP_INSTALL"
