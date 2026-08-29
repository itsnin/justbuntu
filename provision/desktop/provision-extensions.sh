#!/bin/bash
# install optional desktop apps selected during first run, or prompt if called directly
if [[ -v JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS ]]; then
  selected="$JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS"
else
  AVAILABLE_OPTIONAL=("JetBrains Toolbox" "OBS Studio" "Spotify" "Slack" "Discord" "Web Apps")
  selected=$(gum choose "${AVAILABLE_OPTIONAL[@]}" --no-limit --height 10 --header "Select optional desktop applications")
fi
if [[ "$selected" == *"JetBrains Toolbox"* ]]; then
  source $JUSTBUNTU_PATH/provision/desktop/extensions/provision-jetbrains-toolbox.sh
fi
if [[ "$selected" == *"OBS Studio"* ]]; then
  source $JUSTBUNTU_PATH/provision/desktop/extensions/provision-obs-studio.sh
fi
if [[ "$selected" == *"Spotify"* ]]; then
  source $JUSTBUNTU_PATH/provision/desktop/extensions/provision-spotify.sh
fi
if [[ "$selected" == *"Slack"* ]]; then
  source $JUSTBUNTU_PATH/provision/desktop/extensions/provision-slack.sh
fi
if [[ "$selected" == *"Discord"* ]]; then
  source $JUSTBUNTU_PATH/provision/desktop/extensions/provision-discord.sh
fi
if [[ "$selected" == *"Web Apps"* ]]; then
  source $JUSTBUNTU_PATH/provision/desktop/extensions/provision-web-apps.sh
fi
