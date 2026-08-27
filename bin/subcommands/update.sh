#!/bin/bash
CHOICES=(
	"Justbuntu        Update Justbuntu itself"
	"LazyDocker    TUI for Docker"
	"<< Back       "
)
CHOICE=$(gum choose "${CHOICES[@]}" --height 10 --header "Update manually-managed applications")
if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
	# don't update anything
	echo ""
else
	INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
	case "$INSTALLER" in
	"justbuntu") INSTALLER_FILE="$JUSTBUNTU_PATH/bin/subcommands/migrate.sh" ;;
	*) INSTALLER_FILE="$JUSTBUNTU_PATH/install/terminal/app-$INSTALLER.sh" ;;
	esac
	source $INSTALLER_FILE && gum spin --spinner globe --title "Update completed!" -- sleep 3
fi
clear
source $JUSTBUNTU_PATH/bin/justbuntu
