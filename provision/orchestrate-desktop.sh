#!/bin/bash

# Keybindings first. Sets base shortcuts (Super+1-9 = workspaces).
# No user interaction, runs instantly.
run_script "$HOME/.local/share/justbuntu/provision/desktop/configure-keybindings.sh"

# GNOME extensions already handled in the parent orchestrator before the
# unattended phase began (they have interactive popups requiring user attention).

# Run remaining desktop installers
for installer in "$HOME/.local/share/justbuntu/provision/desktop/"*.sh; do
  # Skip keybindings and extensions. Already handled above in specific order.
  [[ "$installer" == *"configure-keybindings.sh" ]] && continue
  [[ "$installer" == *"configure-shell-extensions.sh" ]] && continue
  run_script "$installer"
done

# Logout to pick up changes
if gum confirm "Ready to reboot for all settings to take effect?"; then sudo reboot || true; fi
