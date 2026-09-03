#!/bin/bash
# Install discord via official .deb
(
  cd /tmp
  if wget -q -L -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"; then
    sudo apt install -y ./discord.deb || echo "discord install failed (continuing)"
    rm -f discord.deb
  else
    echo "discord download failed (continuing)"
  fi
)
