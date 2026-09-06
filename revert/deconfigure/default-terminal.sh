#!/bin/bash
# Reset default terminal to GNOME Terminal
gsettings set org.gnome.desktop.default-applications.terminal exec 'gnome-terminal'
rm -f "$HOME/.config/ubuntu-xdg-terminals.list"
