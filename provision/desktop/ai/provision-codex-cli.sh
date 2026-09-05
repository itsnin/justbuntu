#!/bin/bash
# Install OpenAI Codex CLI
# Requires ChatGPT/OpenAI account authentication after installation.
# Download to temp file first, then pipe "n" to any interactive prompts.
TMP_INSTALL=$(mktemp)
if curl -fsSL --retry 3 --retry-delay 5 https://chatgpt.com/codex/install.sh -o "$TMP_INSTALL"; then
  if yes n | sh "$TMP_INSTALL"; then
    echo "codex cli installed. run 'codex' to authenticate and start."
  fi
fi
rm -f "$TMP_INSTALL"
