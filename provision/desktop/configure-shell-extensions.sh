#!/bin/bash
sudo apt install -y gnome-shell-extension-manager gir1.2-gtop-2.0 gir1.2-clutter-1.0 || echo "shell extension deps install failed (continuing)"
pipx install gnome-extensions-cli --system-site-packages
# Turn off default Ubuntu extensions
gnome-extensions disable tiling-assistant@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-appindicators@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true
gnome-extensions disable ding@rastersoft.com 2>/dev/null || true
gnome-extensions disable snapd-prompting@canonical.com 2>/dev/null || true
gnome-extensions disable snapd-search-provider@canonical.com 2>/dev/null || true
# Check first-run preference. Prompts if running directly.
if [[ "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" != "true" && "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" != "false" ]]; then
  if ! gum confirm "Install GNOME extensions? (requires accepting some confirmations during setup)"; then
    echo "skipping gnome extension installation"
    return 0
  fi
elif [[ "$JUSTBUNTU_INSTALL_EXTENSIONS" == "false" ]]; then
  echo "skipping gnome extension installation (disabled in preferences)"
  return 0
fi
# Install all extensions
gext install spotlight@nin || echo "spotlight extension install failed (continuing)"
gext install space-bar@luchrioh || echo "space-bar extension install failed (continuing)"
gext install just-perfection-desktop@just-perfection || echo "just-perfection extension install failed (continuing)"
gext install gsconnect@andyholmes.github.io || echo "gsconnect extension install failed (continuing)"
gext install caffeine@patapon.info || echo "caffeine extension install failed (continuing)"
gext install copyous@boerdereinar.dev || echo "copyous extension install failed (continuing)"
gext install emoji-copy@felipeftn || echo "emoji-copy extension install failed (continuing)"
# Copy extension gsettings schemas system-wide and compile them.
# Standard method that lets gsettings configure extensions.
EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
SCHEMAS_DIR="/usr/share/glib-2.0/schemas"
# Copy all Space Bar schemas. Ships 4 separate files: appearance, behavior, shortcuts, state.
for schema in "$EXTENSIONS_DIR/space-bar@luchrioh"/schemas/*.gschema.xml; do
  [ -f "$schema" ] && sudo cp "$schema" "$SCHEMAS_DIR/" 2>/dev/null || true
done
# Copy Just Perfection schema
[ -f "$EXTENSIONS_DIR/just-perfection-desktop@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml" ] && \
  sudo cp "$EXTENSIONS_DIR/just-perfection-desktop@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml" "$SCHEMAS_DIR/" 2>/dev/null || true
# Copy Copyous schema
[ -f "$EXTENSIONS_DIR/copyous@boerdereinar.dev/schemas/org.gnome.shell.extensions.copyous.gschema.xml" ] && \
  sudo cp "$EXTENSIONS_DIR/copyous@boerdereinar.dev/schemas/org.gnome.shell.extensions.copyous.gschema.xml" "$SCHEMAS_DIR/" 2>/dev/null || true
# Copy Emoji Copy schema
[ -f "$EXTENSIONS_DIR/emoji-copy@felipeftn/schemas/org.gnome.shell.extensions.emoji-copy.gschema.xml" ] && \
  sudo cp "$EXTENSIONS_DIR/emoji-copy@felipeftn/schemas/org.gnome.shell.extensions.emoji-copy.gschema.xml" "$SCHEMAS_DIR/" 2>/dev/null || true
# Compile all schemas
sudo glib-compile-schemas "$SCHEMAS_DIR/" 2>/dev/null || true
# Space Bar extension preferences
# Toggle overview = OFF (behavior schema)
gsettings set org.gnome.shell.extensions.space-bar.behavior toggle-overview false 2>/dev/null || true
# Switch to workspace shortcuts = ON (shortcuts schema)
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-activate-workspace-shortcuts true 2>/dev/null || true
# Move to workspace with current window = ON (shortcuts schema)
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-move-to-workspace-shortcuts true 2>/dev/null || true
# Resolve keybinding conflict: Space Bar's activate-1-key..activate-10-key use Super+1..Super+0
# which conflict with our custom switch-to-workspace-N bindings. Clear the native ones.
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" "@as []" 2>/dev/null || true
done
# Just Perfection extension preferences
# Dash (Visibility tab) = OFF
gsettings set org.gnome.shell.extensions.just-perfection dash false 2>/dev/null || true
# Copyous extension preferences
# Show indicator on top panel = OFF
gsettings set org.gnome.shell.extensions.copyous show-indicator false 2>/dev/null || true
# Wiggle indicator on copy = OFF
gsettings set org.gnome.shell.extensions.copyous wiggle-indicator false 2>/dev/null || true
# Open clipboard dialog shortcut = Super+V. Default is Super+Shift+V.
gsettings set org.gnome.shell.extensions.copyous open-clipboard-dialog-shortcut "['<Super>v']" 2>/dev/null || true
# Profile = Compact. Verified from profiles.js source code.
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
# Child schemas for Compact profile
gsettings set org.gnome.shell.extensions.copyous.file-item:/org/gnome/shell/extensions/copyous/file-item/ file-preview-visibility 'file-info' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.copyous.link-item:/org/gnome/shell/extensions/copyous/link-item/ link-preview-orientation 'horizontal' 2>/dev/null || true
# Resolve GNOME Super+V conflict. Default toggle-message-tray uses ['<Super>v', '<Super>m']
# Remove Super+V, keep Super+M for message tray
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']" 2>/dev/null || true
# Emoji Copy extension preferences
# Always show indicator on top panel = OFF
gsettings set org.gnome.shell.extensions.emoji-copy always-show false 2>/dev/null || true
# Resolve GNOME Super+Period (.) emoji picker conflict
# Disable IBus emoji hotkey so Emoji Copy extension's Super+. works exclusively.
gsettings set org.freedesktop.ibus.panel.emoji hotkey "@as []" 2>/dev/null || true
