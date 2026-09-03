#!/bin/bash
# Set Ghostty as the default terminal emulator.
# gsettings handles Ctrl+Alt+T and GNOME shell launches.
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'

# Ubuntu 25.04+ also reads ~/.config/ubuntu-xdg-terminals.list for the
# Nautilus "Open in Terminal" context menu. Ghostty's desktop file is
# com.mitchellh.ghostty.desktop.
mkdir -p "$HOME/.config"
echo 'com.mitchellh.ghostty.desktop' > "$HOME/.config/ubuntu-xdg-terminals.list"
