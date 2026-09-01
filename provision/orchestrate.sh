#!/bin/bash
# exit immediately if a command exits with a non-zero status.
# -E preserves ERR traps inside functions, required for error handling.
set -eEuo pipefail
# load helpers — logging duplicates output to /var/log/justbuntu-install.log,
# errors provides graceful recovery with retry menu and log inspection.
source "$HOME/.local/share/justbuntu/provision/helpers/logging.sh"
source "$HOME/.local/share/justbuntu/provision/helpers/errors.sh"
# begin logging
start_install_log
# check the distribution name and version and abort if incompatible
source "$HOME/.local/share/justbuntu/provision/core/validate-system.sh"
# ask for development choices
echo "Get ready to make a few choices..."
source "$HOME/.local/share/justbuntu/provision/terminal/prerequisites/provision-gum.sh" >/dev/null
source "$HOME/.local/share/justbuntu/provision/core/configure-snapd.sh"
source "$HOME/.local/share/justbuntu/provision/core/purge-kdump.sh"
source "$HOME/.local/share/justbuntu/provision/core/gather-preferences.sh"
# install terminal tools (always)
echo "Installing terminal tools..."
source "$HOME/.local/share/justbuntu/provision/orchestrate-terminal.sh"
# desktop software and tweaks will only be installed if we're running GNOME
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  echo "Installing desktop tools and tweaks..."
  # temporarily inhibit screen idle/lock using gnome-session-inhibit
  # inhibitor is automatically released when the wrapped process exits
  # this avoids permanently modifying user settings
  gnome-session-inhibit --inhibit idle --reason "JustBuntu installation in progress" \
    bash -c "source $HOME/.local/share/justbuntu/provision/orchestrate-desktop.sh"
else
  echo "GNOME not detected. Skipping desktop-specific tools and tweaks."
fi
# finalize log
stop_install_log
