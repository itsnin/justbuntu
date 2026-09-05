#!/bin/bash
# Revert Emoji Copy extension
gsettings reset-recursively org.gnome.shell.extensions.emoji-copy 2>/dev/null || true
gsettings reset org.freedesktop.ibus.panel.emoji hotkey 2>/dev/null || true
sudo rm -f /usr/share/glib-2.0/schemas/org.gnome.shell.extensions.emoji-copy.gschema.xml 2>/dev/null || true
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ 2>/dev/null || true
gext uninstall emoji-copy@felipeftn 2>/dev/null || true
gnome-extensions uninstall emoji-copy@felipeftn 2>/dev/null || true
