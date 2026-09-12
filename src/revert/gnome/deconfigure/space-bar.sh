#!/bin/bash
# Revert Space Bar extension
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
SCHEMA_DIR="$DATA_HOME/gnome-shell/extensions/space-bar@luchrioh/schemas"
SYSTEM_SCHEMA_DIR="/usr/share/glib-2.0/schemas"
removed=false

remove_system_schema() {
  local schema_file="$1"

  [[ -e "$schema_file" ]] || return 0
  if [[ -L "$schema_file" ]] || ! command -v dpkg-query >/dev/null 2>&1 || dpkg-query -S "$schema_file" >/dev/null 2>&1; then
    printf 'warning: refusing to remove non-JustBuntu schema: %s\n' "$schema_file" >&2
    return 0
  fi
  sudo rm -f -- "$schema_file" 2>/dev/null || true
  removed=true
}

for schema in behavior shortcuts appearance state; do
  gsettings --schemadir "$SCHEMA_DIR" reset-recursively "org.gnome.shell.extensions.space-bar.$schema" 2>/dev/null || true
done
for schema_file in "$SYSTEM_SCHEMA_DIR"/org.gnome.shell.extensions.space-bar.*.gschema.xml; do
  remove_system_schema "$schema_file"
done
if [[ "$removed" == true ]]; then
  sudo glib-compile-schemas "$SYSTEM_SCHEMA_DIR" 2>/dev/null || true
fi
# Restore workspace keybindings
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings reset org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" 2>/dev/null || true
done
gext uninstall space-bar@luchrioh 2>/dev/null || true
gnome-extensions uninstall space-bar@luchrioh 2>/dev/null || true
