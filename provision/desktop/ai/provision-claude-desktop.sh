#!/bin/bash
# Install Claude Desktop via Anthropic's official apt repository
# Add signing key and repository
sudo curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc https://downloads.claude.ai/claude-desktop/key.asc
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" | sudo tee /etc/apt/sources.list.d/claude-desktop.list >/dev/null
# Install
sudo apt-get update >/dev/null
sudo apt-get install -y claude-desktop || echo "claude desktop install failed (continuing)"
