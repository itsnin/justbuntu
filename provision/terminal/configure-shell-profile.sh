#!/bin/bash
# configure the bash shell using JustBuntu defaults
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
cp ~/.local/share/justbuntu/lib/configuration/bashrc ~/.bashrc
# load the PATH for use later in the installers
source ~/.local/share/justbuntu/lib/shell-profile/bash/shell
