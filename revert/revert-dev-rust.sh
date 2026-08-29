#!/bin/bash
# uninstall rust via rustup
if command -v rustup >/dev/null 2>&1; then
  rustup self uninstall -y
fi
# clean up any remaining files
rm -rf "$HOME/.rustup" "$HOME/.cargo"
