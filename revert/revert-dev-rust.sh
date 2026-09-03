#!/bin/bash
# Uninstall Rust via rustup
if command -v rustup >/dev/null 2>&1; then
  rustup self uninstall -y
fi
# Clean up any remaining files
rm -rf "$HOME/.rustup" "$HOME/.cargo"
