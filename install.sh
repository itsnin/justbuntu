#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
# -E preserves ERR traps inside functions. Required for error handling.
set -eEuo pipefail
# Clean up any stale error-handling sentinel from previous runs
rm -f /tmp/justbuntu-error-handled
# Cache sudo credentials FIRST, before any redirects or logging.
# Password prompt goes directly to clean terminal, not through tee buffer.
# User enters password once here; all subsequent sudo commands use cache.
sudo -v
# Load helpers. Logging duplicates output to /var/log/justbuntu-install.log,
# errors provides graceful recovery with retry menu and log inspection.
source "$HOME/.local/share/justbuntu/lib/logging.sh"
source "$HOME/.local/share/justbuntu/lib/errors.sh"
# Begin logging. sudo commands inside use cached credentials from above.
start_install_log
# Check the distribution name and version. Abort if incompatible.
run_script "$HOME/.local/share/justbuntu/core/validate-system.sh"
# Install gum first, needed for interactive prompts
run_script "$HOME/.local/share/justbuntu/provision/install/prerequisites/gum.sh"
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
run_script "$HOME/.local/share/justbuntu/core/gather-preferences.sh"
# Re-enable logging redirect
enable_logging
# END OF INTERACTIVE CHOICES
# Install GNOME extensions NOW, right after user answered the question.
# Extension installation has interactive popup confirmations that the user
# needs to approve while they are still at the keyboard. Must happen
# BEFORE snapd removal and other unattended system changes.
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  run_script "$HOME/.local/share/justbuntu/provision/install/gnome-shell-extensions.sh"
fi
# Refresh sudo credentials cache. Extension installation popups may have
# taken some time, and the long unattended phase follows.
sudo -v
# Install Homebrew. Mandatory package manager for terminal tools (lazygit, etc.)
# and AI tool fallbacks. Installed after extensions so interactive popups happen first.
run_script "$HOME/.local/share/justbuntu/provision/install/prerequisites/homebrew.sh"

# Cross-desktop applications and AI tools. Run regardless of DE.
# Slack, Discord, Spotify, JetBrains, etc. do not need GNOME.
# AI CLIs (Codex, Claude Code, etc.) work in any terminal.
export JUSTBUNTU_PATH="$HOME/.local/share/justbuntu"

# Browsers first. Web apps depend on having a Chromium-based browser.
echo "Installing browsers..."
source "$HOME/.local/share/justbuntu/provision/install/apps/browsers.sh"
echo "Installing cross-desktop applications..."
source "$HOME/.local/share/justbuntu/provision/install/apps/apps.sh"
echo "Installing AI tools..."
source "$HOME/.local/share/justbuntu/provision/install/apps/ai-tools.sh"
# Web apps. Need browser installed first; creates .desktop entries.
if [[ "$JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS" == *"Web Apps"* ]]; then
  echo "Installing web apps..."
  source "$HOME/.local/share/justbuntu/provision/install/apps/web-apps.sh"
fi
# Now apply unattended system changes based on gathered preferences
run_script "$HOME/.local/share/justbuntu/provision/configure/snapd.sh"
run_script "$HOME/.local/share/justbuntu/provision/configure/kdump.sh"
# Install terminal tools (always)
echo "Installing terminal tools..."
source "$HOME/.local/share/justbuntu/core/terminal.sh"
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
      source '$HOME/.local/share/justbuntu/lib/logging.sh'
      source '$HOME/.local/share/justbuntu/lib/errors.sh'
      # Refresh sudo credentials in this subshell context
      sudo -v
      source '$HOME/.local/share/justbuntu/core/desktop.sh'
    "
else
  echo "GNOME not detected. Skipping desktop-specific tools and tweaks."
fi
# Finalize log
stop_install_log
