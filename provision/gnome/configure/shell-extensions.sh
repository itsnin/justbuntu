#!/bin/bash
set -euo pipefail

if [[ "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" != "true" ]]; then
  return 0
fi

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
EXTENSIONS_DIR="$DATA_HOME/gnome-shell/extensions"

compile_extension_schemas() {
  local schema_file schema_dir error

  if [[ ! -d "$EXTENSIONS_DIR" ]]; then
    printf 'warning: GNOME extension directory is missing: %s\n' "$EXTENSIONS_DIR" >&2
    return 1
  fi

  for schema_file in "$EXTENSIONS_DIR"/*/schemas/*.gschema.xml; do
    [[ -f "$schema_file" ]] || continue
    schema_dir="${schema_file%/*}"
    if ! error=$(glib-compile-schemas "$schema_dir" 2>&1); then
      printf 'warning: could not compile schemas in %s: %s\n' "$schema_dir" "$error" >&2
    fi
  done
}

set_global_setting() {
  local error

  if ! error=$(gsettings set "$@" 2>&1); then
    printf 'warning: could not set %s %s: %s\n' "$1" "$2" "$error" >&2
  fi
}

set_extension_setting() {
  local extension="$1"
  local schema="$2"
  local key="$3"
  local value="$4"
  local schema_dir="$EXTENSIONS_DIR/$extension/schemas"
  local error actual

  if [[ ! -d "$schema_dir" ]]; then
    printf 'warning: schema directory missing for %s; skipped %s\n' "$extension" "$key" >&2
    return 1
  fi
  if ! error=$(gsettings --schemadir "$schema_dir" set "$schema" "$key" "$value" 2>&1); then
    printf 'warning: could not set %s %s: %s\n' "$schema" "$key" "$error" >&2
    return 1
  fi
  if ! actual=$(gsettings --schemadir "$schema_dir" get "$schema" "$key" 2>&1); then
    printf 'warning: could not verify %s %s: %s\n' "$schema" "$key" "$actual" >&2
    return 1
  fi
  if [[ "$actual" != "$value" && "$actual" != "'$value'" ]]; then
    printf 'warning: %s %s was not applied; expected %s, got %s\n' \
      "$schema" "$key" "$value" "$actual" >&2
    return 1
  fi
}

extension_is_enabled() {
  local extension="$1"
  local enabled disabled quoted

  if ! enabled=$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null); then
    return 1
  fi
  if ! disabled=$(gsettings get org.gnome.shell disabled-extensions 2>/dev/null); then
    return 1
  fi
  quoted="'$extension'"
  [[ "$enabled" == *"$quoted"* && "$disabled" != *"$quoted"* ]]
}

compile_extension_schemas || true

# Space Bar settings use its installed schema directory.
set_extension_setting space-bar@luchrioh org.gnome.shell.extensions.space-bar.behavior toggle-overview false || true
space_bar_workspace_settings_ready=true
if ! set_extension_setting space-bar@luchrioh org.gnome.shell.extensions.space-bar.shortcuts enable-activate-workspace-shortcuts true; then
  space_bar_workspace_settings_ready=false
fi
if ! set_extension_setting space-bar@luchrioh org.gnome.shell.extensions.space-bar.shortcuts enable-move-to-workspace-shortcuts true; then
  space_bar_workspace_settings_ready=false
fi

# Space Bar owns these workspace shortcuts when its settings are available.
for i in 1 2 3 4 5 6 7 8 9; do
  if ! set_extension_setting space-bar@luchrioh org.gnome.shell.extensions.space-bar.shortcuts "activate-$i-key" "['<Super>$i']"; then
    space_bar_workspace_settings_ready=false
  fi
done
if [[ "$space_bar_workspace_settings_ready" == true ]] && extension_is_enabled space-bar@luchrioh; then
  for i in 1 2 3 4 5 6 7 8 9; do
    set_global_setting org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" "@as []"
  done
else
  printf 'warning: Space Bar workspace settings are not active; keeping native workspace bindings\n' >&2
fi

# Just Perfection settings use its installed schema directory.
set_extension_setting just-perfection-desktop@just-perfection org.gnome.shell.extensions.just-perfection dash false || true

# Copyous settings use its installed schema directory.
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous show-indicator false || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous wiggle-indicator false || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous open-clipboard-dialog-shortcut "['<Super>v']" || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous show-at-pointer true || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous clipboard-orientation 'vertical' || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous clipboard-position-vertical 'fill' || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous clipboard-position-horizontal 'top' || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous auto-hide-search true || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous item-width 300 || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous item-height 100 || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous dynamic-item-height true || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous show-header false || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous header-controls-visibility 'visible-on-hover' || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous.file-item file-preview-visibility 'file-info' || true
set_extension_setting copyous@boerdereinar.dev org.gnome.shell.extensions.copyous.link-item link-preview-orientation 'horizontal' || true

# Keep Super+V for Copyous and Super+Period for Emoji Copy.
set_global_setting org.gnome.shell.keybindings toggle-message-tray "['<Super>m']"
set_extension_setting emoji-copy@felipeftn org.gnome.shell.extensions.emoji-copy always-show false || true
set_global_setting org.freedesktop.ibus.panel.emoji hotkey "@as []"
