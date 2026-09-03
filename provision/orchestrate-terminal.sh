#!/bin/bash

# Needed for all installers
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl git unzip

# Run terminal installers
for installer in "$HOME/.local/share/justbuntu/provision/terminal/"*.sh; do
  run_script "$installer"
done
