#!/bin/bash
# install JetBrains Toolbox App
# download latest version in a subshell to avoid changing parent working directory
(
  TMP_DIR=$(mktemp -d)
  cd "$TMP_DIR"
  if curl -fsSL "https://download.jetbrains.com/toolbox/jetbrains-toolbox-3.7.2.87231.tar.gz" -o jetbrains-toolbox.tar.gz; then
    # extract and install
    tar -xzf jetbrains-toolbox.tar.gz
    TOOLBOX_DIR=$(find . -maxdepth 1 -type d -name "jetbrains-toolbox-*" | head -1)
    if [ -n "$TOOLBOX_DIR" ]; then
      mkdir -p "$HOME/.local/share/JetBrains/Toolbox"
      mv "$TOOLBOX_DIR"/* "$HOME/.local/share/JetBrains/Toolbox/"
      # create symlink for easy access
      mkdir -p "$HOME/.local/bin"
      ln -sf "$HOME/.local/share/JetBrains/Toolbox/jetbrains-toolbox" "$HOME/.local/bin/jetbrains-toolbox"
    fi
  else
    echo "jetbrains toolbox download failed (continuing)"
  fi
  rm -rf "$TMP_DIR"
)
