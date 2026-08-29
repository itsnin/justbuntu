#!/bin/bash
AVAILABLE_LANGUAGES=("Python" "Rust" "Node.js" "Java" "C/C++ Build Tools" "PostgreSQL" "Web Tools")
SELECTED_LANGUAGES="Python,Node.js"
export JUSTBUNTU_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 12 --header "Select development tools")
# optional desktop apps only offered when running gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  AVAILABLE_OPTIONAL=("JetBrains Toolbox" "OBS Studio" "Spotify")
  export JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS=$(gum choose "${AVAILABLE_OPTIONAL[@]}" --no-limit --height 5 --header "Select optional desktop applications")
fi
