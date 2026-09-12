#!/bin/bash
# Uninstall Python development packages and uv
sudo apt-get purge -y python3-pip python3-venv python3-dev python3-full
# Remove uv
rm -rf "$HOME/.local/bin/uv" "$HOME/.local/bin/uvx"
rm -rf "$HOME/.local/share/uv"
