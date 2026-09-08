#!/bin/bash

# Needed for all installers
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl git unzip

# Configure shell profile first. Adds ~/.local/bin to PATH for subsequent installers,
# and sets up bashrc integration so the environment persists after reboot.
run_script "$HOME/.local/share/justbuntu/provision/general/configure/shell-profile.sh"
# Configure git identity and aliases
run_script "$HOME/.local/share/justbuntu/provision/general/configure/git.sh"
# Run terminal installers
run_script "$HOME/.local/share/justbuntu/provision/general/install/terminal/general/fastfetch.sh"
run_script "$HOME/.local/share/justbuntu/provision/general/install/terminal/general/btop.sh"
run_script "$HOME/.local/share/justbuntu/provision/general/install/terminal/general/wget.sh"
run_script "$HOME/.local/share/justbuntu/provision/general/install/terminal/general/curl.sh"
run_script "$HOME/.local/share/justbuntu/provision/general/install/terminal/general/micro.sh"
run_script "$HOME/.local/share/justbuntu/provision/general/install/terminal/general/lazygit.sh"
run_script "$HOME/.local/share/justbuntu/provision/general/install/terminal/general/github-cli.sh"
run_script "$HOME/.local/share/justbuntu/provision/general/install/terminal/languages.sh"
