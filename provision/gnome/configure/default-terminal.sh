#!/bin/bash
# Set Ghostty as the default terminal emulator.
# gsettings handles Ctrl+Alt+T and GNOME shell launches.
if command -v ghostty >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'
else
  echo "warning: ghostty not found, keeping system default terminal"
  exit 0
fi

# Ubuntu 25.04+ also reads ~/.config/ubuntu-xdg-terminals.list for the
# Nautilus "Open in Terminal" context menu. Ghostty's desktop file is
# com.mitchellh.ghostty.desktop.
mkdir -p "$HOME/.config"
echo 'com.mitchellh.ghostty.desktop' > "$HOME/.config/ubuntu-xdg-terminals.list"
