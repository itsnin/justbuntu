#!/bin/bash

if [ $# -eq 0 ]; then
	SUB=$(gum choose "Update" "Install" "Uninstall" "Manual" "Quit" --height 10 --header "" | tr '[:upper:]' '[:lower:]')
else
	SUB=$1
fi

[ -n "$SUB" ] && [ "$SUB" != "quit" ] && source $JUSTBUNTU_PATH/bin/commands/$SUB.sh
