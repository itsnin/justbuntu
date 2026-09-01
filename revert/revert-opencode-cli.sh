#!/bin/bash
# remove opencode cli
rm -rf "$HOME/.opencode" 2>/dev/null || true
rm -f "$HOME/.local/bin/opencode" 2>/dev/null || true
