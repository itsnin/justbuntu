#!/bin/bash
# Install Slack desktop via official .deb
# Parse the latest .deb URL from Slack's download page to avoid hardcoding versions.
(
  cd /tmp || exit 1
  SLACK_DEB_URL=$(curl -fsSL --retry 2 "https://slack.com/downloads/linux" | grep -oP 'https://downloads\.slack-edge\.com[^"]+amd64\.deb' | head -1)

  if [ -z "$SLACK_DEB_URL" ]; then
    echo "warning: could not determine latest Slack download URL"
    echo "skipping Slack installation"
    exit 0
  fi

  if wget -q -L -O slack-desktop.deb "$SLACK_DEB_URL"; then
    sudo apt install -y ./slack-desktop.deb || echo "Slack install failed (continuing)"
    rm -f slack-desktop.deb
  else
    echo "Slack download failed (continuing)"
  fi
)
