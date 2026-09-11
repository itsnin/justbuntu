#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
# -E preserves ERR traps inside functions. Required for error handling.
set -eEuo pipefail
export JUSTBUNTU_PATH="${JUSTBUNTU_PATH:-$HOME/.local/share/justbuntu}"
# Cache sudo credentials FIRST, before any redirects or logging.
# Password prompt goes directly to clean terminal, not through tee buffer.
# User enters password once here; all subsequent sudo commands use cache.
sudo -v
# Load helpers. Logging keeps a redacted copy in the user's private state
# directory; errors provides recovery with report and log inspection.
source "$HOME/.local/share/justbuntu/lib/logging.sh"
source "$HOME/.local/share/justbuntu/lib/errors.sh"

# Keep the cached sudo credential alive during long downloads and package
# installs without prompting again. The loop exits when the credential expires
# or when the installer exits; the next privileged command then reports the
# real authentication failure.
SUDO_KEEPALIVE_PID=""
start_sudo_keepalive() {
  local parent_pid=$$

  (
    trap - ERR EXIT
    while kill -0 "$parent_pid" 2>/dev/null; do
      sudo -n -v >/dev/null 2>&1 || exit 0
      sleep 60
    done
  ) &
  SUDO_KEEPALIVE_PID=$!
}

stop_sudo_keepalive() {
  if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    SUDO_KEEPALIVE_PID=""
  fi
}

start_sudo_keepalive
# errors.sh installs exit_handler; stop the keepalive before it displays an
# error menu or retries the installer.
trap 'stop_sudo_keepalive; exit_handler' EXIT
# Begin logging. sudo commands inside use cached credentials from above.
start_install_log
# Check the distribution name and version. Abort if incompatible.
JUSTBUNTU_PHASE="validation"
export JUSTBUNTU_PHASE
run_script "$HOME/.local/share/justbuntu/core/validate-system.sh"
# Install gum first, needed for interactive prompts
JUSTBUNTU_PHASE="prerequisites"
export JUSTBUNTU_PHASE
run_script "$HOME/.local/share/justbuntu/provision/general/install/prerequisites/gum.sh"
# ALL INTERACTIVE CHOICES HAPPEN HERE
# Gather all preferences upfront before any system modifications begin.
# Restore direct TTY access so gum TUI renders properly (bypasses tee buffer).
restore_tty
echo ""
gum style --bold "==> A few quick choices before we begin"
echo "    Use arrow keys to navigate, Space to select/deselect, Enter to confirm."
echo "    The last question will ask about GNOME extensions — you will see"
echo "    some popup confirmations immediately after if you accept."
echo ""
JUSTBUNTU_PHASE="interactive"
export JUSTBUNTU_PHASE
run_script "$HOME/.local/share/justbuntu/core/gather-preferences.sh"
# Re-enable logging redirect
enable_logging
# END OF INTERACTIVE CHOICES
# Install GNOME extensions NOW, right after user answered the question.
# Extension installation has interactive popup confirmations that the user
# needs to approve while they are still at the keyboard. Must happen
# BEFORE snapd removal and other unattended system changes.
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  JUSTBUNTU_PHASE="gnome-extensions"
  export JUSTBUNTU_PHASE
  run_script "$HOME/.local/share/justbuntu/provision/gnome/install/gnome-shell-extensions.sh"
  # Configure schemas immediately after extension installation, before the
  # unrelated application and desktop phases begin.
  run_script "$HOME/.local/share/justbuntu/provision/gnome/configure/shell-extensions.sh"
fi
# Install Homebrew. Mandatory package manager for terminal tools (lazygit, etc.)
# and AI tool fallbacks. Installed after extensions so interactive popups happen first.
JUSTBUNTU_PHASE="applications"
export JUSTBUNTU_PHASE
run_script "$HOME/.local/share/justbuntu/provision/general/install/prerequisites/homebrew.sh"

# Cross-desktop applications and AI tools. Run regardless of DE.
# Slack, Discord, Spotify, JetBrains, etc. do not need GNOME.
# AI CLIs (Codex, Claude Code, etc.) work in any terminal.
export JUSTBUNTU_PATH="$HOME/.local/share/justbuntu"

# Browsers first. Web apps depend on having a Chromium-based browser.
echo "Installing browsers..."
run_script "$HOME/.local/share/justbuntu/provision/general/install/apps/browsers.sh"
# Ghostty is the default terminal emulator — always installed
run_script "$HOME/.local/share/justbuntu/provision/general/install/apps/ghostty.sh"
echo "Installing cross-desktop applications..."
run_script "$HOME/.local/share/justbuntu/provision/general/install/apps/apps.sh"
echo "Installing AI tools..."
run_script "$HOME/.local/share/justbuntu/provision/general/install/apps/ai-tools.sh"
# Web apps. Need browser installed first; creates .desktop entries.
if [[ "$JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS" == *"Web Apps"* ]]; then
  echo "Installing web apps..."
  run_script "$HOME/.local/share/justbuntu/provision/general/install/apps/web-apps.sh"
fi
# Now apply unattended system changes based on gathered preferences
run_script "$HOME/.local/share/justbuntu/provision/general/configure/snapd.sh"
run_script "$HOME/.local/share/justbuntu/provision/general/configure/kdump.sh"
# Install terminal tools (always)
echo "Installing terminal tools..."
JUSTBUNTU_PHASE="terminal"
export JUSTBUNTU_PHASE
run_script "$HOME/.local/share/justbuntu/core/terminal.sh"
# Desktop software and tweaks will only be installed if we're running GNOME
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  echo "Installing desktop tools and tweaks..."
  JUSTBUNTU_PHASE="desktop"
  export JUSTBUNTU_PHASE
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
      # The parent installer owns failure reporting for this child process.
      source '$HOME/.local/share/justbuntu/core/desktop.sh'
    "
else
  echo "GNOME not detected. Skipping desktop-specific tools and tweaks."
fi
# Finalize log
stop_install_log
