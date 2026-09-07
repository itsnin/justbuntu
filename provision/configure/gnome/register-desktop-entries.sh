#!/bin/bash

# Ensure JustBuntu CLI is executable
chmod +x "$HOME/.local/share/justbuntu/bin/justbuntu" 2>/dev/null || true
for script in "$HOME/.local/share/justbuntu/share/"*.sh; do source "$script"; done
# Refresh desktop database so entries appear in app grid
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
