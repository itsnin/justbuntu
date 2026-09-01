#!/bin/bash
# remove codex cli
rm -rf "$HOME/.config/codex" 2>/dev/null || true
rm -f "$HOME/.local/bin/codex" 2>/dev/null || true
