#!/bin/bash
# Remove OpenCode CLI. Handles both direct binary and Homebrew installations.
rm -rf "$HOME/.opencode" 2>/dev/null || true
rm -f "$HOME/.local/bin/opencode" 2>/dev/null || true
# Also uninstall from Homebrew if it was installed that way
if command -v brew >/dev/null 2>&1; then
  brew uninstall anomalyco/tap/opencode 2>/dev/null || true
fi
