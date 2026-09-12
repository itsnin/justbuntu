#!/bin/bash
source "$JUSTBUNTU_PATH/lib/interactive.sh"

CHOICES=(
  "Reset All Components        Revert everything provisioned. justbuntu core stays intact."
  "Select Individual Components  Choose specific items to revert."
  "<< Back                     "
)
CHOICE=$(justbuntu_select "Revert provisioned components" "" single "${CHOICES[@]}")
if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  clear
  source "$JUSTBUNTU_ROOT/bin/justbuntu"
  exit 0
fi
if [[ "$CHOICE" == "Reset All Components"* ]]; then
  if justbuntu_confirm "This will revert all provisioned apps and settings. justbuntu core will remain. Continue?" yes; then
    source "$JUSTBUNTU_PATH/revert/all.sh"
    if justbuntu_confirm "Reset complete. Reboot for all changes to take effect?" yes; then
      sudo reboot || true
    fi
  fi
else
  mapfile -t UNINSTALLER_OPTIONS < <(
    find "$JUSTBUNTU_PATH/revert" -type f -name '*.sh' ! -name 'all.sh' -print | sort
  )
  UNINSTALLER=$(justbuntu_select "Select a component to revert" "" single "${UNINSTALLER_OPTIONS[@]}")
  if [[ -n "$UNINSTALLER" ]]; then
    justbuntu_confirm "Run $(basename "$UNINSTALLER")?" yes && source "$UNINSTALLER"
  fi
fi
clear
source "$JUSTBUNTU_ROOT/bin/justbuntu"
