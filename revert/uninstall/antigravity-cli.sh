#!/bin/bash
# Remove Antigravity CLI (Google). Binary is 'agy'.
rm -rf "$HOME/.antigravity" 2>/dev/null || true
rm -rf "$HOME/.config/antigravity" 2>/dev/null || true
rm -f "$HOME/.local/bin/agy" 2>/dev/null || true
rm -f "$HOME/.local/bin/antigravity" 2>/dev/null || true
