#!/bin/bash
# Revert Just Perfection extension
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
SCHEMA_DIR="$DATA_HOME/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas"
SYSTEM_SCHEMA_DIR="/usr/share/glib-2.0/schemas"
SYSTEM_SCHEMA_FILE="$SYSTEM_SCHEMA_DIR/org.gnome.shell.extensions.just-perfection.gschema.xml"

if [[ -e "$SYSTEM_SCHEMA_FILE" && ! -L "$SYSTEM_SCHEMA_FILE" ]] && command -v dpkg-query >/dev/null 2>&1 && ! dpkg-query -S "$SYSTEM_SCHEMA_FILE" >/dev/null 2>&1; then
  sudo rm -f -- "$SYSTEM_SCHEMA_FILE" 2>/dev/null || true
  sudo glib-compile-schemas "$SYSTEM_SCHEMA_DIR" 2>/dev/null || true
fi
gsettings --schemadir "$SCHEMA_DIR" reset-recursively org.gnome.shell.extensions.just-perfection 2>/dev/null || true
gext uninstall just-perfection-desktop@just-perfection 2>/dev/null || true
gnome-extensions uninstall just-perfection-desktop@just-perfection 2>/dev/null || true
