#!/bin/bash
# install slack desktop via official .deb
(
  cd /tmp
  if wget -q -L -O slack-desktop.deb "https://slack.com/downloads/instructions/linux?ddl=1&build=deb"; then
    sudo apt install -y ./slack-desktop.deb || echo "slack install failed (continuing)"
    rm -f slack-desktop.deb
  else
    echo "slack download failed (continuing)"
  fi
)
