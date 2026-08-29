#!/bin/bash
# uninstall web apps by removing their .desktop files and icons
rm -f "$HOME/.local/share/applications/ChatGPT.desktop"
rm -f "$HOME/.local/share/applications/Google Photos.desktop"
rm -f "$HOME/.local/share/applications/Google Contacts.desktop"
rm -f "$HOME/.local/share/applications/Tailscale.desktop"
rm -f "$HOME/.local/share/applications/icons/ChatGPT.png"
rm -f "$HOME/.local/share/applications/icons/Google Photos.png"
rm -f "$HOME/.local/share/applications/icons/Google Contacts.png"
rm -f "$HOME/.local/share/applications/icons/Tailscale.png"
