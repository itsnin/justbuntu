#!/bin/bash
# Install lazygit via Homebrew for latest version
if command -v brew >/dev/null 2>&1; then
  brew install lazygit 2>/dev/null || echo "lazygit brew install failed (continuing)"
else
  echo "homebrew not available, skipping lazygit install (continuing)"
fi
