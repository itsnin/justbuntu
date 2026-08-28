#!/bin/bash
# exit immediately if a command exits with a non-zero status
set -e
# give people a chance to retry running the installation
trap 'echo "JustBuntu installation failed! You can retry by running: source ~/.local/share/justbuntu/install.sh"' ERR
# check the distribution name and version and abort if incompatible
source ~/.local/share/justbuntu/install/check-version.sh
# ask for development choices
echo "Get ready to make a few choices..."
source ~/.local/share/justbuntu/install/terminal/required/app-gum.sh >/dev/null
source ~/.local/share/justbuntu/install/select-snapd.sh
source ~/.local/share/justbuntu/install/remove-kdump.sh
source ~/.local/share/justbuntu/install/first-run-choices.sh
# install terminal tools (always)
echo "Installing terminal tools..."
source ~/.local/share/justbuntu/install/terminal.sh
# desktop software and tweaks will only be installed if we're running GNOME
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  echo "Installing desktop tools and tweaks..."
  # temporarily inhibit screen idle/lock using gnome-session-inhibit
  # inhibitor is automatically released when the wrapped process exits
  # this avoids permanently modifying user settings
  gnome-session-inhibit --inhibit idle --reason "JustBuntu installation in progress" \
    bash -c "source ~/.local/share/justbuntu/install/desktop.sh"
else
  echo "GNOME not detected. Skipping desktop-specific tools and tweaks."
fi
