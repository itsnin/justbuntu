#!/bin/bash

# needed for all installers
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl git unzip

# run terminal installers
for installer in ~/.local/share/justbuntu/provision/terminal/*.sh; do source $installer; done
