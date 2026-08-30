#!/bin/bash
# install ai assistants. separate category from optional apps. user chooses.
if [[ -v JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS ]]; then
  selected="$JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS"
else
  AI_OPTIONS=("Claude Desktop")
  selected=$(gum choose "${AI_OPTIONS[@]}" --no-limit --height 6 --header "Select AI assistants (optional)")
fi
if [[ "$selected" == *"Claude Desktop"* ]]; then
  source $JUSTBUNTU_PATH/provision/desktop/ai/provision-claude-desktop.sh
fi
