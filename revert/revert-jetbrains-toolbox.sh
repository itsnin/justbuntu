#!/bin/bash
# remove jetbrains toolbox and its applications
rm -rf "$HOME/.local/share/JetBrains/Toolbox"
rm -f "$HOME/.local/bin/jetbrains-toolbox"
rm -rf "$HOME/.cache/JetBrains"
# remove desktop entries
rm -f "$HOME/.local/share/applications/jetbrains-toolbox.desktop"
find "$HOME/.local/share/applications" -name "jetbrains-*.desktop" -delete
