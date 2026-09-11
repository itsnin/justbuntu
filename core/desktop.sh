#!/bin/bash

# Run GNOME configuration after the early extension installation phase.
run_script "$HOME/.local/share/justbuntu/provision/gnome/configure/keybindings.sh"

# Extension-specific settings run here, after their extensions and schemas exist.
for installer in "$HOME/.local/share/justbuntu/provision/gnome/configure/"*.sh; do
  [[ "$installer" == *"disable-ubuntu-extensions.sh" ]] && continue
  [[ "$installer" == *"keybindings.sh" ]] && continue
  [[ "$installer" == *"shell-extensions.sh" ]] && continue
  run_script "$installer"
done
# Extension installation already ran in the parent orchestrator while popups
# were visible. Skip it here so each extension is installed exactly once.
for installer in "$HOME/.local/share/justbuntu/provision/gnome/install/"*.sh; do
  [[ "$installer" == *"gnome-shell-extensions.sh" ]] && continue
  run_script "$installer"
done

# Return Gum to the real terminal before asking the reboot question. Normal
# installer output is redirected to the private log stream, but this choice
# must remain visible and interactive.
restore_tty
if gum confirm --default=false --affirmative "Yes" --negative "No" \
  "Ready to reboot for all settings to take effect?"; then
  enable_logging
  sudo reboot || true
else
  printf '%s\n' 'Installation finished. Reboot skipped.'
  enable_logging
fi
