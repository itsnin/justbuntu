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
      # ensure toolbox binary is executable
      chmod +x "$HOME/.local/share/JetBrains/Toolbox/jetbrains-toolbox"
      # create symlink for easy access
      mkdir -p "$HOME/.local/bin"
      ln -sf "$HOME/.local/share/JetBrains/Toolbox/jetbrains-toolbox" "$HOME/.local/bin/jetbrains-toolbox"
      # create desktop entry so it appears in the app grid
      mkdir -p "$HOME/.local/share/applications"
      # find icon file (name varies between versions)
      TOOLBOX_ICON=""
      for icon_name in "toolbox.svg" "jetbrains-toolbox.svg" "icon.svg"; do
        if [ -f "$HOME/.local/share/JetBrains/Toolbox/$icon_name" ]; then
          TOOLBOX_ICON="$HOME/.local/share/JetBrains/Toolbox/$icon_name"
          break
        fi
      done
      cat > "$HOME/.local/share/applications/jetbrains-toolbox.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=JetBrains Toolbox
Comment=Manage your JetBrains IDEs
Exec=$HOME/.local/share/JetBrains/Toolbox/jetbrains-toolbox
Icon=${TOOLBOX_ICON}
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF
      chmod +x "$HOME/.local/share/applications/jetbrains-toolbox.desktop"
      # refresh desktop database so it appears in the app grid
      update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
    fi
  else
    echo "jetbrains toolbox download failed (continuing)"
  fi
  rm -rf "$TMP_DIR"
)
