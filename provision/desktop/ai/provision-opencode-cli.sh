#!/bin/bash
# install OpenCode CLI
# requires LLM API keys to be configured after installation
# primary method: official install script
if curl -fsSL --retry 3 --retry-delay 5 https://opencode.ai/install | bash; then
  echo "opencode cli installed via official script. run 'opencode' to configure API keys."
else
  echo "opencode.ai install script failed, trying homebrew..."
  # fallback: homebrew (requires homebrew to be installed first)
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
