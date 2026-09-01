#!/bin/bash
# remove claude code cli
rm -rf "$HOME/.claude" 2>/dev/null || true
rm -f "$HOME/.local/bin/claude" 2>/dev/null || true
