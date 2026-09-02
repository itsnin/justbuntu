#!/bin/bash
sudo apt install -y fastfetch btop wget curl micro
# install lazygit via homebrew for latest version
if command -v brew >/dev/null 2>&1; then
  brew install lazygit 2>/dev/null || echo "lazygit brew install failed (continuing)"
else
  echo "homebrew not available, skipping lazygit install (continuing)"
fi
