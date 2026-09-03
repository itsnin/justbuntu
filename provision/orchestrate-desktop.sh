#!/bin/bash

# gnome extensions run FIRST — they have interactive popups that need user attention
# while they are still at the keyboard. prerequisites (gir packages, pipx,
# gnome-extensions-cli) are installed inside the script itself via sudo apt.
if [[ "${JUSTBUNTU_INSTALL_EXTENSIONS:-}" == "true" ]]; then
  run_script "$HOME/.local/share/justbuntu/provision/desktop/configure-shell-extensions.sh"
fi

# run remaining desktop installers
for installer in "$HOME/.local/share/justbuntu/provision/desktop/"*.sh; do
  # skip extensions — already handled above
  [[ "$installer" == *"configure-shell-extensions.sh" ]] && continue
  run_script "$installer"
done

# logout to pickup changes
gum confirm "Ready to reboot for all settings to take effect?" && sudo reboot || true
