#!/bin/bash
# Revert Just Perfection extension
gsettings reset-recursively org.gnome.shell.extensions.just-perfection 2>/dev/null || true
sudo rm -f /usr/share/glib-2.0/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml 2>/dev/null || true
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ 2>/dev/null || true
gext uninstall just-perfection-desktop@just-perfection 2>/dev/null || true
gnome-extensions uninstall just-perfection-desktop@just-perfection 2>/dev/null || true
