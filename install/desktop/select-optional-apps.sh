#!/bin/bash
# install optional desktop apps selected during first run, or prompt if called directly

if [[ -v JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS ]]; then
  selected="$JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS"
else
  AVAILABLE_OPTIONAL=("JetBrains Toolbox" "OBS Studio" "Spotify" "Web Apps")
  selected=$(gum choose "${AVAILABLE_OPTIONAL[@]}" --no-limit --height 6 --header "Select optional desktop applications")
fi

if [[ "$selected" == *"JetBrains Toolbox"* ]]; then
  source $JUSTBUNTU_PATH/install/desktop/optional/app-jetbrains-toolbox.sh
fi

if [[ "$selected" == *"OBS Studio"* ]]; then
  source $JUSTBUNTU_PATH/install/desktop/optional/app-obs-studio.sh
fi

if [[ "$selected" == *"Spotify"* ]]; then
  source $JUSTBUNTU_PATH/install/desktop/optional/app-spotify.sh
fi

if [[ "$selected" == *"Web Apps"* ]]; then
  source $JUSTBUNTU_PATH/install/desktop/optional/select-web-apps.sh
fi
