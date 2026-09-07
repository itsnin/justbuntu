#!/bin/bash

# Needed for all installers
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl git unzip

# Configure shell profile first. Adds ~/.local/bin to PATH for subsequent installers,
# and sets up bashrc integration so the environment persists after reboot.
run_script "$HOME/.local/share/justbuntu/provision/configure/shell-profile.sh"
# Configure git identity and aliases
run_script "$HOME/.local/share/justbuntu/provision/configure/git.sh"
# Run terminal installers
for installer in "$HOME/.local/share/justbuntu/provision/install/terminal/"*.sh; do
  run_script "$installer"
done
