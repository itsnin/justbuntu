#!/bin/bash
# Install cross-desktop applications selected during first run.
# These run regardless of desktop environment — no GNOME required.
if [[ -v JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS ]]; then
  selected="$JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS"
else
  AVAILABLE_OPTIONAL=("JetBrains Toolbox" "Slack" "Discord" "GitHub Desktop" "VS Code" "Obsidian" "Element" "Web Apps")
  selected=$(gum choose "${AVAILABLE_OPTIONAL[@]}" --no-limit --height 12 --show-help=false --header "Select optional applications (Space: toggle, Enter: confirm)")
fi
# Always-installed cross-desktop utilities
source "$JUSTBUNTU_PATH/provision/general/install/apps/vlc.sh"
source "$JUSTBUNTU_PATH/provision/general/install/apps/obs-studio.sh"
source "$JUSTBUNTU_PATH/provision/general/install/apps/spotify.sh"
source "$JUSTBUNTU_PATH/provision/general/install/apps/localsend.sh"
source "$JUSTBUNTU_PATH/provision/general/install/apps/appimagelauncher.sh"

if [[ "$selected" == *"JetBrains Toolbox"* ]]; then
  source "$JUSTBUNTU_PATH/provision/general/install/apps/optional/jetbrains-toolbox.sh"
fi
if [[ "$selected" == *"Slack"* ]]; then
  source "$JUSTBUNTU_PATH/provision/general/install/apps/optional/slack.sh"
fi
if [[ "$selected" == *"Discord"* ]]; then
  source "$JUSTBUNTU_PATH/provision/general/install/apps/optional/discord.sh"
fi
if [[ "$selected" == *"GitHub Desktop"* ]]; then
  source "$JUSTBUNTU_PATH/provision/general/install/apps/optional/github-desktop.sh"
fi
if [[ "$selected" == *"VS Code"* ]]; then
  source "$JUSTBUNTU_PATH/provision/general/install/apps/optional/vscode.sh"
fi
if [[ "$selected" == *"Obsidian"* ]]; then
  source "$JUSTBUNTU_PATH/provision/general/install/apps/optional/obsidian.sh"
fi
if [[ "$selected" == *"Element"* ]]; then
  source "$JUSTBUNTU_PATH/provision/general/install/apps/optional/element.sh"
fi
