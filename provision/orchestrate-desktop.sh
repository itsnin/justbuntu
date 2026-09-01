#!/bin/bash

# run desktop installers
for installer in "$HOME/.local/share/justbuntu/provision/desktop/"*.sh; do source "$installer"; done

# logout to pickup changes
gum confirm "Ready to reboot for all settings to take effect?" && sudo reboot || true
