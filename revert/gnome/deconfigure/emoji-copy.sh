#!/bin/bash
# Revert Emoji Copy extension
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
SCHEMA_DIR="$DATA_HOME/gnome-shell/extensions/emoji-copy@felipeftn/schemas"
gsettings --schemadir "$SCHEMA_DIR" reset-recursively org.gnome.shell.extensions.emoji-copy 2>/dev/null || true
gsettings reset org.freedesktop.ibus.panel.emoji hotkey 2>/dev/null || true
gext uninstall emoji-copy@felipeftn 2>/dev/null || true
gnome-extensions uninstall emoji-copy@felipeftn 2>/dev/null || true
