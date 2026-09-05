#!/bin/bash
# Install OpenCode CLI
# Requires LLM API keys to be configured after installation.
# Primary method: official install script. Download to temp file first,
# then pipe "n" to any interactive prompts.
TMP_INSTALL=$(mktemp)
if curl -fsSL --retry 3 --retry-delay 5 https://opencode.ai/install -o "$TMP_INSTALL"; then
  if yes n | bash "$TMP_INSTALL"; then
    echo "opencode cli installed via official script. run 'opencode' to configure API keys."
    rm -f "$TMP_INSTALL"
  else
    rm -f "$TMP_INSTALL"
    echo "opencode.ai install script failed, trying homebrew..."
    # Fallback: Homebrew. Requires Homebrew to be installed first.
    if command -v brew >/dev/null 2>&1; then
      if brew install anomalyco/tap/opencode 2>/dev/null; then
        echo "opencode cli installed via homebrew. run 'opencode' to configure API keys."
      else
        echo "opencode cli homebrew install also failed (continuing)"
      fi
    else
      echo "homebrew not available, skipping opencode fallback (continuing)"
    fi
  fi
else
  rm -f "$TMP_INSTALL"
  echo "opencode.ai install script download failed, trying homebrew..."
  if command -v brew >/dev/null 2>&1; then
    if brew install anomalyco/tap/opencode 2>/dev/null; then
      echo "opencode cli installed via homebrew. run 'opencode' to configure API keys."
    else
      echo "opencode cli homebrew install also failed (continuing)"
    fi
  else
    echo "homebrew not available, skipping opencode fallback (continuing)"
  fi
fi
