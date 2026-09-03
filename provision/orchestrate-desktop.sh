#!/bin/bash

# keybindings first — sets base shortcuts (Super+1-9 = workspaces).
# no user interaction, runs instantly.
run_script "$HOME/.local/share/justbuntu/provision/desktop/configure-keybindings.sh"

# gnome extensions next — they have interactive popups that need user attention
# while they are still at the keyboard. space bar extension may clear Super+1-9
# shortcuts (set above) to avoid conflicts, so it must run after keybindings.
# prerequisites (gir packages, pipx, gnome-extensions-cli) are installed inside
# the script itself via sudo apt.
if [[ "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" == "true" ]]; then
  run_script "$HOME/.local/share/justbuntu/provision/desktop/configure-shell-extensions.sh"
fi

# run remaining desktop installers
for installer in "$HOME/.local/share/justbuntu/provision/desktop/"*.sh; do
  # skip keybindings and extensions — already handled above in specific order
  [[ "$installer" == *"configure-keybindings.sh" ]] && continue
  [[ "$installer" == *"configure-shell-extensions.sh" ]] && continue
  run_script "$installer"
done

# logout to pickup changes
gum confirm "Ready to reboot for all settings to take effect?" && sudo reboot || true
