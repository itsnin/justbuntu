#!/bin/bash
sudo apt install -y gnome-shell-extension-manager gir1.2-gtop-2.0 gir1.2-clutter-1.0
pipx install gnome-extensions-cli --system-site-packages
# turn off default Ubuntu extensions
gnome-extensions disable tiling-assistant@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-appindicators@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true
gnome-extensions disable ding@rastersoft.com 2>/dev/null || true
# pause to assure user is ready to accept confirmations
if gum confirm "To install Gnome extensions, you need to accept some confirmations. Ready?"; then
  # install Spotlight extension
  gext install spotlight@nin || echo "spotlight extension install failed (continuing)"
else
  echo "skipping spotlight extension installation"
fi
