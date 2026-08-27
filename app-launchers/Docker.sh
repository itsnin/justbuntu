#!/bin/bash
cat <<EOF >~/.local/share/applications/Docker.desktop
[Desktop Entry]
Version=1.0
Name=Docker
Comment=Manage Docker containers with LazyDocker
Exec=ghostty --class=Docker --title=Docker -e lazydocker
Terminal=false
Type=Application
Icon=$HOME/.local/share/justbuntu/app-launchers/icons/Docker.png
Categories=GTK;
StartupNotify=false
EOF
