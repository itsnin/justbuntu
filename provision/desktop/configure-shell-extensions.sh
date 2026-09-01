#!/bin/bash
sudo apt install -y gnome-shell-extension-manager gir1.2-gtop-2.0 gir1.2-clutter-1.0 || echo "shell extension deps install failed (continuing)"
pipx install gnome-extensions-cli --system-site-packages
# turn off default Ubuntu extensions
gnome-extensions disable tiling-assistant@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-appindicators@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true
gnome-extensions disable ding@rastersoft.com 2>/dev/null || true
# pause to assure user is ready to accept confirmations
if gum confirm "To install Gnome extensions, you need to accept some confirmations. Ready?"; then
  # install Spotlight extension (app launcher)
  gext install spotlight@nin || echo "spotlight extension install failed (continuing)"
  # install Space Bar (workspace indicator in top bar)
  gext install space-bar@luchrioh || echo "space-bar extension install failed (continuing)"
  # install Just Perfection (tweak GNOME shell behavior)
  gext install just-perfection-desktop@just-perfection || echo "just-perfection extension install failed (continuing)"
  # install GSConnect (connect mobile devices via KDE Connect protocol)
  gext install gsconnect@andyholmes.github.io || echo "gsconnect extension install failed (continuing)"
  # install Caffeine (prevent screen lock/suspend temporarily)
  gext install caffeine@patapon.info || echo "caffeine extension install failed (continuing)"
else
  echo "skipping gnome extension installation"
fi
