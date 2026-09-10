#!/bin/bash
# Revert Copyous clipboard manager extension
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
SCHEMA_DIR="$DATA_HOME/gnome-shell/extensions/copyous@boerdereinar.dev/schemas"
gsettings --schemadir "$SCHEMA_DIR" reset-recursively org.gnome.shell.extensions.copyous 2>/dev/null || true
gsettings --schemadir "$SCHEMA_DIR" reset-recursively org.gnome.shell.extensions.copyous.file-item 2>/dev/null || true
gsettings --schemadir "$SCHEMA_DIR" reset-recursively org.gnome.shell.extensions.copyous.link-item 2>/dev/null || true
gsettings reset org.gnome.shell.keybindings toggle-message-tray 2>/dev/null || true
gext uninstall copyous@boerdereinar.dev 2>/dev/null || true
gnome-extensions uninstall copyous@boerdereinar.dev 2>/dev/null || true
