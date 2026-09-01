#!/bin/bash
# configure the bash shell using JustBuntu defaults
[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
cp "$HOME/.local/share/justbuntu/config/bashrc" "$HOME/.bashrc"
# load the PATH for use later in the installers
source "$HOME/.local/share/justbuntu/shell/bash/shell"
