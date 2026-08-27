#!/bin/bash
CHOICES=(
  "Dev Language      Install programming languages and tools"
  "Dev Database      Install development database in Docker"
  "JetBrains Toolbox Manage JetBrains IDEs"
  "OBS Studio        Record screencasts with inputs from display + webcam"
  "Spotify           Stream music"
  "Web Apps          Install web apps with their own icon and shell"
  "> All             Re-run any of the default installers"
  "<< Back           "
)
CHOICE=$(gum choose "${CHOICES[@]}" --height 16 --header "Install additional components")
if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  # Don't install anything
  echo ""
elif [[ "$CHOICE" == "> All"* ]]; then
  INSTALLER_FILE=$(gum file $JUSTBUNTU_PATH/install)
  [[ -n "$INSTALLER_FILE" ]] &&
    gum confirm "Run installer?" &&
    source $INSTALLER_FILE &&
    gum spin --spinner globe --title "Install completed!" -- sleep 3
else
  INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
  case "$INSTALLER" in
  "dev-language") INSTALLER_FILE="$JUSTBUNTU_PATH/install/terminal/select-dev-language.sh" ;;
  "dev-database") INSTALLER_FILE="$JUSTBUNTU_PATH/install/terminal/select-dev-storage.sh" ;;
  "jetbrains-toolbox") INSTALLER_FILE="$JUSTBUNTU_PATH/install/desktop/optional/app-jetbrains-toolbox.sh" ;;
  "web-apps") INSTALLER_FILE="$JUSTBUNTU_PATH/install/desktop/optional/select-web-apps.sh" ;;
  "obs-studio") INSTALLER_FILE="$JUSTBUNTU_PATH/install/desktop/optional/app-obs-studio.sh" ;;
  "spotify") INSTALLER_FILE="$JUSTBUNTU_PATH/install/desktop/optional/app-spotify.sh" ;;
  esac
  source $INSTALLER_FILE && gum spin --spinner globe --title "Install completed!" -- sleep 3
fi
clear
source $JUSTBUNTU_PATH/bin/justbuntu
