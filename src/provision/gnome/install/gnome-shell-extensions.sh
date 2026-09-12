#!/bin/bash
source "$JUSTBUNTU_PATH/lib/interactive.sh"

# Check first-run preference. Prompts if running directly.
if [[ "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" == "false" ]]; then
  echo "skipping gnome extension installation (disabled in preferences)"
  return 0
elif [[ "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" != "true" ]]; then
  if ! justbuntu_confirm "Install GNOME extensions? (requires accepting some confirmations during setup)" yes; then
    echo "skipping gnome extension installation"
    return 0
  fi
fi

# Disable conflicts before installing replacements.
source "$JUSTBUNTU_PATH/provision/gnome/configure/disable-ubuntu-extensions.sh"

# These dependencies are needed by the extension manager and CLI.
sudo apt install -y gnome-shell-extension-manager gir1.2-gtop-2.0 gir1.2-clutter-1.0 pipx || echo "shell extension deps install failed (continuing)"
export PATH="$HOME/.local/bin:$PATH"
pipx install gnome-extensions-cli --system-site-packages

GNOME_EXTENSIONS=(
  "spotlight@nin"
  "space-bar@luchrioh"
  "just-perfection-desktop@just-perfection"
  "gsconnect@andyholmes.github.io"
  "caffeine@patapon.info"
  "copyous@boerdereinar.dev"
  "emoji-copy@felipeftn"
)

for extension in "${GNOME_EXTENSIONS[@]}"; do
  if ! gext install "$extension"; then
    echo "$extension extension install failed (continuing)"
  fi
done
