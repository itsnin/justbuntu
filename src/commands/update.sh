#!/bin/bash
source "$JUSTBUNTU_PATH/lib/interactive.sh"

CHOICES=(
	"JustBuntu        Update JustBuntu itself"
	"<< Back       "
)
CHOICE=$(justbuntu_select "Update manually-managed applications" "" single "${CHOICES[@]}")
if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
	# Don't update anything
	echo ""
else
	INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
	case "$INSTALLER" in
	"justbuntu") INSTALLER_FILE="$JUSTBUNTU_PATH/commands/migrate.sh" ;;
	esac
	source "$INSTALLER_FILE"
fi
clear
source "$JUSTBUNTU_ROOT/bin/justbuntu"
