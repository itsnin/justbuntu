#!/bin/bash
# Remove Claude Code CLI
rm -rf "$HOME/.claude" 2>/dev/null || true
rm -f "$HOME/.local/bin/claude" 2>/dev/null || true
