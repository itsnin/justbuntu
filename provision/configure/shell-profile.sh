#!/bin/bash
# Configure the bash shell to load JustBuntu environment.
# Appends a single source line to the user's existing .bashrc rather than
# replacing it. Preserves all user aliases, customizations, and preferences.
# Idempotent: does nothing if the source line already exists.
# Backup only created once, never overwritten on subsequent runs.
BASHRC_LINE='source "$HOME/.local/share/justbuntu/shell/bash/rc"'
BASHRC_FILE="$HOME/.bashrc"
BACKUP_FILE="$HOME/.bashrc.bak"
# Create backup of original bashrc only if backup doesn't already exist
# This preserves the user's genuine original even across multiple runs
if [ -f "$BASHRC_FILE" ] && [ ! -f "$BACKUP_FILE" ]; then
  cp "$BASHRC_FILE" "$BACKUP_FILE"
fi
# Create bashrc if it doesn't exist at all
if [ ! -f "$BASHRC_FILE" ]; then
  touch "$BASHRC_FILE"
fi
# Append our source line only if not already present
# grep -F treats pattern as fixed string; $ is not a regex anchor
if ! grep -qxF "$BASHRC_LINE" "$BASHRC_FILE"; then
  {
    echo ""
    echo "# JustBuntu — load shell environment"
    printf '%s\n' "$BASHRC_LINE"
  } >> "$BASHRC_FILE"
fi
# Load the PATH for use later in the installers
source "$HOME/.local/share/justbuntu/shell/bash/shell"
