#!/bin/bash
CHOICES=(
  "Reset All Components        Revert everything provisioned. justbuntu core stays intact."
  "Select Individual Components  Choose specific items to revert."
  "<< Back                     "
)
CHOICE=$(gum choose "${CHOICES[@]}" --height 8 --header "Revert provisioned components")
if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  clear
  source "$JUSTBUNTU_PATH/bin/justbuntu"
  exit 0
fi
if [[ "$CHOICE" == "Reset All Components"* ]]; then
  if gum confirm "This will revert all provisioned apps and settings. justbuntu core will remain. Continue?"; then
    gum spin --spinner globe --title "Resetting all components..." -- bash -c "source '$JUSTBUNTU_PATH/revert/revert-all-components.sh'"
    if gum confirm "Reset complete. Reboot for all changes to take effect?"; then sudo reboot || true; fi
  fi
else
  UNINSTALLER=$(gum file "$JUSTBUNTU_PATH/revert" --height 26)
  if [[ -n "$UNINSTALLER" ]] && [[ "$(basename "$UNINSTALLER")" != "revert-all-components.sh" ]]; then
    gum confirm "Run $(basename "$UNINSTALLER")?" &&
      source "$UNINSTALLER" &&
      gum spin --spinner globe --title "Revert completed!" -- sleep 2
  fi
fi
clear
source "$JUSTBUNTU_PATH/bin/justbuntu"
