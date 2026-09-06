#!/bin/bash
# Remove Antigravity CLI (agy)
rm -rf "$HOME/.config/antigravity" 2>/dev/null || true
rm -f "$HOME/.local/bin/agy" 2>/dev/null || true
