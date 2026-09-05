#!/bin/bash

# Keybindings first. Sets base shortcuts (Super+1-9 = workspaces).
# No user interaction, runs instantly.
run_script "$HOME/.local/share/justbuntu/provision/desktop/configure-keybindings.sh"

# GNOME extensions next. They have interactive popups that need user attention
# while they're still at the keyboard. Space Bar extension may clear Super+1-9
# shortcuts (set above) to avoid conflicts. Must run after keybindings.
if [[ "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" == "true" ]]; then
  run_script "$HOME/.local/share/justbuntu/provision/desktop/configure-shell-extensions.sh"
fi

# Run remaining desktop installers
for installer in "$HOME/.local/share/justbuntu/provision/desktop/"*.sh; do
  # Skip keybindings and extensions. Already handled above in specific order.
  [[ "$installer" == *"configure-keybindings.sh" ]] && continue
  [[ "$installer" == *"configure-shell-extensions.sh" ]] && continue
  run_script "$installer"
done

# Logout to pick up changes
if gum confirm "Ready to reboot for all settings to take effect?"; then sudo reboot || true; fi
