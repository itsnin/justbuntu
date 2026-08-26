#!/bin/bash
# Install JetBrains Toolbox App
# Download latest version
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -fsSL "https://data.services.jetbrains.com/products/download?code=TBA&platform=linux" -o jetbrains-toolbox.tar.gz
# Extract and install
tar -xzf jetbrains-toolbox.tar.gz
TOOLBOX_DIR=$(find . -maxdepth 1 -type d -name "jetbrains-toolbox-*" | head -1)
if [ -n "$TOOLBOX_DIR" ]; then
  mkdir -p "$HOME/.local/share/JetBrains/Toolbox"
  mv "$TOOLBOX_DIR"/* "$HOME/.local/share/JetBrains/Toolbox/"
  # Create symlink for easy access
  mkdir -p "$HOME/.local/bin"
  ln -sf "$HOME/.local/share/JetBrains/Toolbox/jetbrains-toolbox" "$HOME/.local/bin/jetbrains-toolbox"
fi
# Cleanup
cd -
rm -rf "$TMP_DIR"
