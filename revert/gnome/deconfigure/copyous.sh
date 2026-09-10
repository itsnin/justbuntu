#!/bin/bash
# Revert Copyous clipboard manager extension
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
SCHEMA_DIR="$DATA_HOME/gnome-shell/extensions/copyous@boerdereinar.dev/schemas"
SYSTEM_SCHEMA_DIR="/usr/share/glib-2.0/schemas"
SYSTEM_SCHEMA_FILE="$SYSTEM_SCHEMA_DIR/org.gnome.shell.extensions.copyous.gschema.xml"

if [[ -e "$SYSTEM_SCHEMA_FILE" && ! -L "$SYSTEM_SCHEMA_FILE" ]] && command -v dpkg-query >/dev/null 2>&1 && ! dpkg-query -S "$SYSTEM_SCHEMA_FILE" >/dev/null 2>&1; then
  sudo rm -f -- "$SYSTEM_SCHEMA_FILE" 2>/dev/null || true
  sudo glib-compile-schemas "$SYSTEM_SCHEMA_DIR" 2>/dev/null || true
fi
gsettings --schemadir "$SCHEMA_DIR" reset-recursively org.gnome.shell.extensions.copyous 2>/dev/null || true
gsettings --schemadir "$SCHEMA_DIR" reset-recursively org.gnome.shell.extensions.copyous.file-item 2>/dev/null || true
gsettings --schemadir "$SCHEMA_DIR" reset-recursively org.gnome.shell.extensions.copyous.link-item 2>/dev/null || true
gsettings reset org.gnome.shell.keybindings toggle-message-tray 2>/dev/null || true
gext uninstall copyous@boerdereinar.dev 2>/dev/null || true
gnome-extensions uninstall copyous@boerdereinar.dev 2>/dev/null || true
