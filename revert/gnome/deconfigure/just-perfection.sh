#!/bin/bash
# Revert Just Perfection extension
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
SCHEMA_DIR="$DATA_HOME/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas"
gsettings --schemadir "$SCHEMA_DIR" reset-recursively org.gnome.shell.extensions.just-perfection 2>/dev/null || true
gext uninstall just-perfection-desktop@just-perfection 2>/dev/null || true
gnome-extensions uninstall just-perfection-desktop@just-perfection 2>/dev/null || true
