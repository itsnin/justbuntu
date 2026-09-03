#!/bin/bash
# Revert Space Bar extension
gsettings reset-recursively org.gnome.shell.extensions.space-bar.behavior 2>/dev/null || true
gsettings reset-recursively org.gnome.shell.extensions.space-bar.shortcuts 2>/dev/null || true
gsettings reset-recursively org.gnome.shell.extensions.space-bar.appearance 2>/dev/null || true
gsettings reset-recursively org.gnome.shell.extensions.space-bar.state 2>/dev/null || true
sudo rm -f /usr/share/glib-2.0/schemas/org.gnome.shell.extensions.space-bar.*.gschema.xml 2>/dev/null || true
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ 2>/dev/null || true
# Restore workspace keybindings
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings reset org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" 2>/dev/null || true
done
gext uninstall space-bar@luchrioh 2>/dev/null || true
gnome-extensions uninstall space-bar@luchrioh 2>/dev/null || true
