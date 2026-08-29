#!/bin/bash
# install slack desktop via official .deb
(
  cd /tmp
  if wget -q -O slack-desktop.deb "https://downloads.slack-edge.com/releases/linux/4.31.155/prod/x64/slack-desktop-4.31.155-amd64.deb"; then
    sudo apt install -y ./slack-desktop.deb || echo "slack install failed (continuing)"
    rm -f slack-desktop.deb
  else
    echo "slack download failed (continuing)"
  fi
)
