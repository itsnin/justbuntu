#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
# -E preserves ERR traps inside functions. Required for error handling.
set -eEuo pipefail
# Clean up any stale error-handling sentinel from previous runs
rm -f /tmp/justbuntu-error-handled
# Load helpers. Logging duplicates output to /var/log/justbuntu-install.log,
# errors provides graceful recovery with retry menu and log inspection.
source "$HOME/.local/share/justbuntu/provision/helpers/logging.sh"
source "$HOME/.local/share/justbuntu/provision/helpers/errors.sh"
# Begin logging
start_install_log
# Check the distribution name and version. Abort if incompatible.
run_script "$HOME/.local/share/justbuntu/provision/core/validate-system.sh"
# Cache sudo credentials upfront. Default timeout is 15 minutes.
# User enters password once here, and all subsequent sudo commands work.
sudo -v
# Install gum first, needed for interactive prompts
run_script "$HOME/.local/share/justbuntu/provision/terminal/prerequisites/provision-gum.sh"
# Install homebrew early — mandatory package manager
run_script "$HOME/.local/share/justbuntu/provision/terminal/prerequisites/provision-homebrew.sh"
# ALL INTERACTIVE CHOICES HAPPEN HERE
# Gather all preferences upfront before any system modifications begin.
# Restore direct TTY access so gum TUI renders properly (bypasses tee buffer).
restore_tty
echo ""
gum style --bold "==> A few quick choices before we begin"
echo "    Use arrow keys to navigate, Enter to confirm, Space to toggle."
echo ""
run_script "$HOME/.local/share/justbuntu/provision/core/gather-preferences.sh"
# Re-enable logging redirect for the non-interactive installation phase
enable_logging
# END OF INTERACTIVE CHOICES
# Refresh sudo credentials cache after interactive phase.
# Default sudo timeout is 15 minutes — if the user took their time with
# the choices above, credentials may have expired and need re-validation.
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
      export PATH=\$HOME/.local/bin:\$PATH
      # Ensure Homebrew is available in this subshell. Check both possible install locations.
      if [ -x '/home/linuxbrew/.linuxbrew/bin/brew' ]; then
        eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)\"
      elif [ -x \"\$HOME/.linuxbrew/bin/brew\" ]; then
        eval \"\$( \"\$HOME/.linuxbrew/bin/brew\" shellenv bash)\"
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
