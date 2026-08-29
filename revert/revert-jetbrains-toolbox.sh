#!/bin/bash
# remove jetbrains toolbox and its applications
rm -rf ~/.local/share/JetBrains/Toolbox
rm -f ~/.local/bin/jetbrains-toolbox
rm -rf ~/.cache/JetBrains
# remove desktop entries
rm -f ~/.local/share/applications/jetbrains-toolbox.desktop
find ~/.local/share/applications -name "jetbrains-*.desktop" -delete
