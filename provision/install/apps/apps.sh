#!/bin/bash
# Install cross-desktop applications selected during first run.
# These run regardless of desktop environment — no GNOME required.
if [[ -v JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS ]]; then
  selected="$JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS"
else
  AVAILABLE_OPTIONAL=("JetBrains Toolbox" "OBS Studio" "Spotify" "Slack" "Discord" "GitHub Desktop" "VLC" "VS Code" "Obsidian" "LocalSend" "Element" "AppImageLauncher" "Ghostty")
  selected=$(gum choose "${AVAILABLE_OPTIONAL[@]}" --no-limit --height 12 --header "Select optional applications")
fi
if [[ "$selected" == *"JetBrains Toolbox"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/optional/jetbrains-toolbox.sh"
fi
if [[ "$selected" == *"OBS Studio"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/optional/obs-studio.sh"
fi
if [[ "$selected" == *"Spotify"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/optional/spotify.sh"
fi
if [[ "$selected" == *"Slack"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/optional/slack.sh"
fi
if [[ "$selected" == *"Discord"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/optional/discord.sh"
fi
if [[ "$selected" == *"GitHub Desktop"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/optional/github-desktop.sh"
fi
if [[ "$selected" == *"VLC"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/vlc.sh"
fi
if [[ "$selected" == *"VS Code"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/vscode.sh"
fi
if [[ "$selected" == *"Obsidian"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/obsidian.sh"
fi
if [[ "$selected" == *"LocalSend"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/localsend.sh"
fi
if [[ "$selected" == *"Element"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/element.sh"
fi
if [[ "$selected" == *"AppImageLauncher"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/appimagelauncher.sh"
fi
if [[ "$selected" == *"Ghostty"* ]]; then
  source "$JUSTBUNTU_PATH/provision/install/apps/ghostty.sh"
fi
