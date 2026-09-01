#!/bin/bash
CHOICES=(
  "Dev Language      Install programming languages and tools"
  "JetBrains Toolbox Manage JetBrains IDEs"
  "OBS Studio        Record screencasts with inputs from display + webcam"
  "Spotify           Stream music"
  "Slack             Team communication and collaboration"
  "Discord           Voice, video and text chat"
  "Claude Desktop    AI assistant with chat, code, and cowork"
  "Web Apps          Install web apps with their own icon and shell"
  "> All             Re-run any of the default installers"
  "<< Back           "
)
CHOICE=$(gum choose "${CHOICES[@]}" --height 22 --header "Install additional components")
if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  # don't install anything
  echo ""
elif [[ "$CHOICE" == "> All"* ]]; then
  INSTALLER_FILE=$(gum file $JUSTBUNTU_PATH/provision)
  [[ -n "$INSTALLER_FILE" ]] &&
    gum confirm "Run installer?" &&
    source "$INSTALLER_FILE" &&
    gum spin --spinner globe --title "Install completed!" -- sleep 3
else
  INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
  case "$INSTALLER" in
  "dev-language") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/terminal/provision-dev-tooling.sh" ;;
  "jetbrains-toolbox") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-jetbrains-toolbox.sh" ;;
  "obs-studio") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-obs-studio.sh" ;;
  "spotify") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-spotify.sh" ;;
  "slack") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-slack.sh" ;;
  "discord") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-discord.sh" ;;
  "claude-desktop") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/ai/provision-claude-desktop.sh" ;;
  "web-apps") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-web-apps.sh" ;;
  esac
  source "$INSTALLER_FILE" && gum spin --spinner globe --title "Install completed!" -- sleep 3
fi
clear
source "$JUSTBUNTU_PATH"/bin/justbuntu
