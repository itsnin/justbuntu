#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e
# Give people a chance to retry running the installation
trap 'echo "Justbuntu installation failed! You can retry by running: source ~/.local/share/justbuntu/install.sh"' ERR
# Check the distribution name and version and abort if incompatible
source ~/.local/share/justbuntu/install/check-version.sh
# Ask for development choices
echo "Get ready to make a few choices..."
source ~/.local/share/justbuntu/install/terminal/required/app-gum.sh >/dev/null
source ~/.local/share/justbuntu/install/select-snapd.sh
source ~/.local/share/justbuntu/install/first-run-choices.sh
# Install terminal tools (always)
echo "Installing terminal tools..."
source ~/.local/share/justbuntu/install/terminal.sh
# Desktop software and tweaks will only be installed if we're running GNOME
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  # Ensure computer doesn't go to sleep or lock while installing
  gsettings set org.gnome.desktop.screensaver lock-enabled false
  gsettings set org.gnome.desktop.session idle-delay 0
  echo "Installing desktop tools and tweaks..."
  source ~/.local/share/justbuntu/install/desktop.sh
  # Revert to normal idle and lock settings
  gsettings set org.gnome.desktop.screensaver lock-enabled true
  gsettings set org.gnome.desktop.session idle-delay 300
else
  echo "GNOME not detected. Skipping desktop-specific tools and tweaks."
fi
