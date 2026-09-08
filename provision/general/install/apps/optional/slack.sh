#!/bin/bash
# Install Slack desktop via direct .deb download
(
  TMP_DEB=$(mktemp)
  trap 'rm -f "$TMP_DEB"' RETURN
  if wget -q -O "$TMP_DEB" "https://downloads.slack-edge.com/desktop-releases/linux/x64/4.52.155/slack-desktop-4.52.155-amd64.deb"; then
    sudo apt install -y "$TMP_DEB" || echo "Slack install failed (continuing)"
  else
    echo "Slack download failed (continuing)"
  fi
)
