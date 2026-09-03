#!/bin/bash
# Install Slack desktop via official direct .deb
(
  cd /tmp || exit 1
  if wget -q -L -O slack-desktop.deb "https://downloads.slack-edge.com/desktop-releases/linux/x64/4.51.191/slack-desktop-4.51.191-amd64.deb"; then
    sudo apt install -y ./slack-desktop.deb || echo "Slack install failed (continuing)"
    rm -f slack-desktop.deb
  else
    echo "Slack download failed (continuing)"
  fi
)
