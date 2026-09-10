#!/bin/bash
set -euo pipefail

if [[ "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" != "true" ]]; then
  return 0
fi

EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
SCHEMAS_DIR="/usr/share/glib-2.0/schemas"

copy_schema() {
  local schema="$1"
  if [[ -f "$schema" ]]; then
    sudo cp "$schema" "$SCHEMAS_DIR/" 2>/dev/null || true
  fi
}

# Install schemas after the extension files exist so gsettings can find them.
for schema in "$EXTENSIONS_DIR/space-bar@luchrioh"/schemas/*.gschema.xml; do
  copy_schema "$schema"
done
copy_schema "$EXTENSIONS_DIR/just-perfection-desktop@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml"
copy_schema "$EXTENSIONS_DIR/copyous@boerdereinar.dev/schemas/org.gnome.shell.extensions.copyous.gschema.xml"
copy_schema "$EXTENSIONS_DIR/emoji-copy@felipeftn/schemas/org.gnome.shell.extensions.emoji-copy.gschema.xml"
sudo glib-compile-schemas "$SCHEMAS_DIR/" 2>/dev/null || true

# Space Bar settings depend on its schemas and installed extension.
gsettings set org.gnome.shell.extensions.space-bar.behavior toggle-overview false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-activate-workspace-shortcuts true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-move-to-workspace-shortcuts true 2>/dev/null || true

# Space Bar owns these workspace shortcuts, so clear the native bindings.
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" "@as []" 2>/dev/null || true
done

# Just Perfection settings.
gsettings set org.gnome.shell.extensions.just-perfection dash false 2>/dev/null || true

# Copyous settings.
gsettings set org.gnome.shell.extensions.copyous show-indicator false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous wiggle-indicator false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous open-clipboard-dialog-shortcut "['<Super>v']" 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous show-at-pointer true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous clipboard-orientation 'vertical' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous clipboard-position-vertical 'fill' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous clipboard-position-horizontal 'top' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous auto-hide-search true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous item-width 300 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous item-height 100 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous dynamic-item-height true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous show-header false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous header-controls-visibility 'visible-on-hover' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous.file-item:/org/gnome/shell/extensions/copyous/file-item/ file-preview-visibility 'file-info' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous.link-item:/org/gnome/shell/extensions/copyous/link-item/ link-preview-orientation 'horizontal' 2>/dev/null || true

# Keep Super+V for Copyous and Super+Period for Emoji Copy.
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']" 2>/dev/null || true
gsettings set org.gnome.shell.extensions.emoji-copy always-show false 2>/dev/null || true
gsettings set org.freedesktop.ibus.panel.emoji hotkey "@as []" 2>/dev/null || true
