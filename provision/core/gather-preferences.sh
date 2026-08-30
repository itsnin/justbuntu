#!/bin/bash
AVAILABLE_LANGUAGES=("Python" "Rust" "Go" "Node.js" "Java" "C/C++ Build Tools" "PostgreSQL" "Web Tools")
SELECTED_LANGUAGES="Python,Node.js"
export JUSTBUNTU_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 12 --header "Select development tools")
# optional desktop apps only offered when running gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  AVAILABLE_OPTIONAL=("JetBrains Toolbox" "OBS Studio" "Spotify" "Slack" "Discord" "Web Apps")
  export JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS=$(gum choose "${AVAILABLE_OPTIONAL[@]}" --no-limit --height 10 --header "Select optional desktop applications")
  # ai assistants — separate category, optional
  AVAILABLE_AI=("Claude Desktop")
  export JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS=$(gum choose "${AVAILABLE_AI[@]}" --no-limit --height 6 --header "Select AI assistants (optional)")
fi
