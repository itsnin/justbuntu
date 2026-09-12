#!/bin/bash

if [ $# -eq 0 ]; then
	source "$JUSTBUNTU_PATH/lib/interactive.sh"
	SUB=$(justbuntu_select "JustBuntu" "" single "Update" "Install" "Uninstall" "Migrate" "Manual" "Quit" | tr '[:upper:]' '[:lower:]')
else
	SUB=$1
fi

[ -n "$SUB" ] && [ "$SUB" != "quit" ] && source "$JUSTBUNTU_PATH/commands/$SUB.sh"
