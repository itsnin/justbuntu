#!/bin/bash
cat <<EOF >~/.local/share/applications/JustBuntu.desktop
[Desktop Entry]
Version=1.0
Name=JustBuntu
Comment=JustBuntu Controls
Exec=ghostty --class=JustBuntu --title=JustBuntu -e justbuntu
Terminal=false
Type=Application
Icon=$HOME/.local/share/justbuntu/share/icons/JustBuntu.png
Categories=GTK;
StartupNotify=false
EOF
