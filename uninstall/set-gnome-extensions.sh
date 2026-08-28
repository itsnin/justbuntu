#!/bin/bash
# re-enable default ubuntu extensions
gnome-extensions enable tiling-assistant@ubuntu.com 2>/dev/null || true
gnome-extensions enable ubuntu-appindicators@ubuntu.com 2>/dev/null || true
gnome-extensions enable ubuntu-dock@ubuntu.com 2>/dev/null || true
gnome-extensions enable ding@rastersoft.com 2>/dev/null || true
# uninstall spotlight extension
gext uninstall spotlight@nin 2>/dev/null || true
gnome-extensions uninstall spotlight@nin 2>/dev/null || true
# remove extension manager packages
sudo apt purge -y gnome-shell-extension-manager gir1.2-gtop-2.0 gir1.2-clutter-1.0
pipx uninstall gnome-extensions-cli 2>/dev/null || true
