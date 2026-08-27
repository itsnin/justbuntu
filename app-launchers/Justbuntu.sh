#!/bin/bash
cat <<EOF >~/.local/share/applications/Justbuntu.desktop
[Desktop Entry]
Version=1.0
Name=Justbuntu
Comment=Justbuntu Controls
Exec=ghostty --class=Justbuntu --title=Justbuntu -e justbuntu
Terminal=false
Type=Application
Icon=$HOME/.local/share/justbuntu/app-launchers/icons/Justbuntu.png
Categories=GTK;
StartupNotify=false
EOF
