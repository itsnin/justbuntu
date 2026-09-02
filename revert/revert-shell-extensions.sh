#!/bin/bash
# re-enable default ubuntu extensions
gnome-extensions enable tiling-assistant@ubuntu.com 2>/dev/null || true
gnome-extensions enable ubuntu-appindicators@ubuntu.com 2>/dev/null || true
gnome-extensions enable ubuntu-dock@ubuntu.com 2>/dev/null || true
gnome-extensions enable ding@rastersoft.com 2>/dev/null || true
gnome-extensions enable snapd-prompting@canonical.com 2>/dev/null || true
gnome-extensions enable snapd-search-provider@canonical.com 2>/dev/null || true
# reset extension gsettings and remove system-installed schemas
gsettings reset-recursively org.gnome.shell.extensions.space-bar.behavior 2>/dev/null || true
gsettings reset-recursively org.gnome.shell.extensions.space-bar.shortcuts 2>/dev/null || true
gsettings reset-recursively org.gnome.shell.extensions.space-bar.appearance 2>/dev/null || true
gsettings reset-recursively org.gnome.shell.extensions.space-bar.state 2>/dev/null || true
gsettings reset-recursively org.gnome.shell.extensions.just-perfection 2>/dev/null || true
gsettings reset-recursively org.gnome.shell.extensions.copyous 2>/dev/null || true
gsettings reset-recursively org.gnome.shell.extensions.emoji-copy 2>/dev/null || true
# restore GNOME keybindings we modified
gsettings reset org.gnome.shell.keybindings toggle-message-tray 2>/dev/null || true
gsettings reset org.freedesktop.ibus.panel.emoji hotkey 2>/dev/null || true
# clean up system-installed schemas
sudo rm -f /usr/share/glib-2.0/schemas/org.gnome.shell.extensions.space-bar.*.gschema.xml 2>/dev/null || true
sudo rm -f /usr/share/glib-2.0/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml 2>/dev/null || true
sudo rm -f /usr/share/glib-2.0/schemas/org.gnome.shell.extensions.copyous.gschema.xml 2>/dev/null || true
sudo rm -f /usr/share/glib-2.0/schemas/org.gnome.shell.extensions.emoji-copy.gschema.xml 2>/dev/null || true
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ 2>/dev/null || true
# restore workspace keybindings that we cleared for space bar
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings reset org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" 2>/dev/null || true
done
# uninstall all justbuntu extensions
gext uninstall spotlight@nin 2>/dev/null || true
gnome-extensions uninstall spotlight@nin 2>/dev/null || true
gext uninstall space-bar@luchrioh 2>/dev/null || true
gnome-extensions uninstall space-bar@luchrioh 2>/dev/null || true
gext uninstall just-perfection-desktop@just-perfection 2>/dev/null || true
gnome-extensions uninstall just-perfection-desktop@just-perfection 2>/dev/null || true
gext uninstall gsconnect@andyholmes.github.io 2>/dev/null || true
gnome-extensions uninstall gsconnect@andyholmes.github.io 2>/dev/null || true
gext uninstall caffeine@patapon.info 2>/dev/null || true
gnome-extensions uninstall caffeine@patapon.info 2>/dev/null || true
gext uninstall copyous@boerdereinar.dev 2>/dev/null || true
gnome-extensions uninstall copyous@boerdereinar.dev 2>/dev/null || true
gext uninstall emoji-copy@felipeftn 2>/dev/null || true
gnome-extensions uninstall emoji-copy@felipeftn 2>/dev/null || true
# remove extension manager packages
sudo apt purge -y gnome-shell-extension-manager gir1.2-gtop-2.0 gir1.2-clutter-1.0
pipx uninstall gnome-extensions-cli 2>/dev/null || true
