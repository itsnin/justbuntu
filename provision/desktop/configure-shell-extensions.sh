#!/bin/bash
sudo apt install -y gnome-shell-extension-manager gir1.2-gtop-2.0 gir1.2-clutter-1.0 || echo "shell extension deps install failed (continuing)"
pipx install gnome-extensions-cli --system-site-packages
# turn off default Ubuntu extensions
gnome-extensions disable tiling-assistant@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-appindicators@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true
gnome-extensions disable ding@rastersoft.com 2>/dev/null || true
gnome-extensions disable snapd-prompting@canonical.com 2>/dev/null || true
gnome-extensions disable snapd-search-provider@canonical.com 2>/dev/null || true
# check first-run preference (or prompt if running directly)
if [[ "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" != "true" && "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" != "false" ]]; then
  if ! gum confirm "Install GNOME extensions? (requires accepting some confirmations during setup)"; then
    echo "skipping gnome extension installation"
    return 0
  fi
elif [[ "$JUSTBUNTU_INSTALL_EXTENSIONS" == "false" ]]; then
  echo "skipping gnome extension installation (disabled in preferences)"
  return 0
fi
# install all 5 extensions
gext install spotlight@nin || echo "spotlight extension install failed (continuing)"
gext install space-bar@luchrioh || echo "space-bar extension install failed (continuing)"
gext install just-perfection-desktop@just-perfection || echo "just-perfection extension install failed (continuing)"
gext install gsconnect@andyholmes.github.io || echo "gsconnect extension install failed (continuing)"
gext install caffeine@patapon.info || echo "caffeine extension install failed (continuing)"
# copy extension gsettings schemas system-wide and compile them.
# this is the standard method that allows gsettings to configure extensions.
EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
SCHEMAS_DIR="/usr/share/glib-2.0/schemas"
# copy all Space Bar schemas (ships 4 separate files: appearance, behavior, shortcuts, state)
for schema in "$EXTENSIONS_DIR/space-bar@luchrioh"/schemas/*.gschema.xml; do
  [ -f "$schema" ] && sudo cp "$schema" "$SCHEMAS_DIR/" 2>/dev/null || true
done
# copy Just Perfection schema
[ -f "$EXTENSIONS_DIR/just-perfection-desktop@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml" ] && \
  sudo cp "$EXTENSIONS_DIR/just-perfection-desktop@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml" "$SCHEMAS_DIR/" 2>/dev/null || true
# compile all schemas
sudo glib-compile-schemas "$SCHEMAS_DIR/" 2>/dev/null || true
# configure Space Bar extension preferences
# Toggle overview = OFF (behavior schema)
gsettings set org.gnome.shell.extensions.space-bar.behavior toggle-overview false 2>/dev/null || true
# Switch to workspace shortcuts = ON (shortcuts schema)
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-activate-workspace-shortcuts true 2>/dev/null || true
# Move to workspace with current window = ON (shortcuts schema)
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-move-to-workspace-shortcuts true 2>/dev/null || true
# resolve keybinding conflict: Space Bar's activate-1-key..activate-10-key use Super+1..Super+0
# which conflict with our custom switch-to-workspace-N bindings. clear the native ones.
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" "@as []" 2>/dev/null || true
done
# configure Just Perfection extension preferences
# Dash (Visibility tab) = OFF
gsettings set org.gnome.shell.extensions.just-perfection dash false 2>/dev/null || true
