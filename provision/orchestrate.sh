#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
# -E preserves ERR traps inside functions. Required for error handling.
set -eEuo pipefail
# Load helpers. Logging duplicates output to /var/log/justbuntu-install.log,
# errors provides graceful recovery with retry menu and log inspection.
source "$HOME/.local/share/justbuntu/provision/helpers/logging.sh"
source "$HOME/.local/share/justbuntu/provision/helpers/errors.sh"
# Begin logging
start_install_log
# Check the distribution name and version. Abort if incompatible.
run_script "$HOME/.local/share/justbuntu/provision/core/validate-system.sh"
# Install gum first, needed for interactive prompts
run_script "$HOME/.local/share/justbuntu/provision/terminal/prerequisites/provision-gum.sh"
# Install homebrew early — mandatory package manager
run_script "$HOME/.local/share/justbuntu/provision/terminal/prerequisites/provision-homebrew.sh"
# ALL INTERACTIVE CHOICES HAPPEN HERE
# Gather all preferences upfront before any system modifications begin
echo "Get ready to make a few choices..."
run_script "$HOME/.local/share/justbuntu/provision/core/gather-preferences.sh"
# END OF INTERACTIVE CHOICES
# Refresh sudo credentials cache so user is not re-prompted during long install
sudo -v
# Now apply all system changes based on gathered preferences
run_script "$HOME/.local/share/justbuntu/provision/core/configure-snapd.sh"
run_script "$HOME/.local/share/justbuntu/provision/core/purge-kdump.sh"
# Install terminal tools (always)
echo "Installing terminal tools..."
source "$HOME/.local/share/justbuntu/provision/orchestrate-terminal.sh"
# Desktop software and tweaks will only be installed if we're running GNOME
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  echo "Installing desktop tools and tweaks..."
  # Temporarily inhibit screen idle/lock using gnome-session-inhibit
  # Inhibitor is automatically released when the wrapped process exits
  # This avoids permanently modifying user settings
  gnome-session-inhibit --inhibit idle --reason "JustBuntu installation in progress" \
    bash -c "
      set -eEuo pipefail
      export PATH="\$HOME/.local/bin:\$PATH"
      # Ensure Homebrew is available in this subshell
      if [ -x '/home/linuxbrew/.linuxbrew/bin/brew' ]; then
        eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)\"
      fi
      source '$HOME/.local/share/justbuntu/provision/helpers/logging.sh'
      source '$HOME/.local/share/justbuntu/provision/helpers/errors.sh'
      source '$HOME/.local/share/justbuntu/provision/orchestrate-desktop.sh'
    "
else
  echo "GNOME not detected. Skipping desktop-specific tools and tweaks."
fi
# Finalize log
stop_install_log
