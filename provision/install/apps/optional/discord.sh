#!/bin/bash
# Install discord via official .deb
(
  TMP_DIR=$(mktemp -d) && cd "$TMP_DIR" || exit 1
  if wget -q -L -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"; then
    sudo apt install -y ./discord.deb || echo "discord install failed (continuing)"
    rm -rf "$TMP_DIR"
  else
    echo "discord download failed (continuing)"
  fi
)
