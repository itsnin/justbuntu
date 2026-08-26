#!/bin/bash
# Configure the bash shell using Justbuntu defaults
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
cp ~/.local/share/justbuntu/configs/bashrc ~/.bashrc
# Load the PATH for use later in the installers
source ~/.local/share/justbuntu/shell-defaults/bash/shell
