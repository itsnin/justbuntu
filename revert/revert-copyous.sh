#!/bin/bash
# revert copyous clipboard manager extension
gsettings reset-recursively org.gnome.shell.extensions.copyous 2>/dev/null || true
gsettings reset org.gnome.shell.keybindings toggle-message-tray 2>/dev/null || true
sudo rm -f /usr/share/glib-2.0/schemas/org.gnome.shell.extensions.copyous.gschema.xml 2>/dev/null || true
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ 2>/dev/null || true
gext uninstall copyous@boerdereinar.dev 2>/dev/null || true
gnome-extensions uninstall copyous@boerdereinar.dev 2>/dev/null || true
