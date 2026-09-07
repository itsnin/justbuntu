#!/bin/bash
# Uninstall lazygit. Tries Homebrew first, then falls back to apt.
if command -v brew >/dev/null 2>&1; then
  brew uninstall lazygit 2>/dev/null || true
fi
sudo apt-get purge -y lazygit 2>/dev/null || true
