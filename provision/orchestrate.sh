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
# Restore TTY briefly so the sudo password prompt is clean and visible.
# Tee buffer can mangle interactive prompts.
restore_tty
# Cache sudo credentials upfront. Default timeout is 15 minutes.
# User enters password once here, and all subsequent sudo commands work.
sudo -v
# Re-enable logging redirect for the provisioning steps
enable_logging
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
echo "    The last question will ask about GNOME extensions — you will see"
echo "    some popup confirmations immediately after if you accept."
echo ""
run_script "$HOME/.local/share/justbuntu/provision/core/gather-preferences.sh"
# Re-enable logging redirect
enable_logging
# END OF INTERACTIVE CHOICES
# Install GNOME extensions NOW, right after user answered the question.
# Extension installation has interactive popup confirmations that the user
# needs to approve while they are still at the keyboard. Must happen
# BEFORE snapd removal and other unattended system changes.
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  run_script "$HOME/.local/share/justbuntu/provision/desktop/configure-shell-extensions.sh"
fi
# Refresh sudo credentials cache. Extension installation popups may have
# taken some time, and the long unattended phase follows.
sudo -v
# Now apply unattended system changes based on gathered preferences
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
      # Refresh sudo credentials in this subshell context
      sudo -v
      source '$HOME/.local/share/justbuntu/provision/orchestrate-desktop.sh'
    "
else
  echo "GNOME not detected. Skipping desktop-specific tools and tweaks."
fi
# Finalize log
stop_install_log
