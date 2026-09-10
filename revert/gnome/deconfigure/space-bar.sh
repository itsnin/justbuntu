#!/bin/bash
# Revert Space Bar extension
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
SCHEMA_DIR="$DATA_HOME/gnome-shell/extensions/space-bar@luchrioh/schemas"
for schema in behavior shortcuts appearance state; do
  gsettings --schemadir "$SCHEMA_DIR" reset-recursively "org.gnome.shell.extensions.space-bar.$schema" 2>/dev/null || true
done
# Restore workspace keybindings
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings reset org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" 2>/dev/null || true
done
gext uninstall space-bar@luchrioh 2>/dev/null || true
gnome-extensions uninstall space-bar@luchrioh 2>/dev/null || true
