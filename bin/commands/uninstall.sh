#!/bin/bash

UNINSTALLER=$(gum file $JUSTBUNTU_PATH/revert --height 26)
[ -n "$UNINSTALLER" ] && gum confirm "Run uninstaller?" && source $UNINSTALLER && gum spin --spinner globe --title "Uninstall completed!" -- sleep 3
clear
source $JUSTBUNTU_PATH/bin/justbuntu
