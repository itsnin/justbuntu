#!/bin/bash
source "$JUSTBUNTU_PATH/lib/interactive.sh"

# Run GNOME configuration after the early extension installation phase.
run_script "$JUSTBUNTU_PATH/provision/gnome/configure/keybindings.sh"

# Extension-specific settings run here, after their extensions and schemas exist.
for installer in "$JUSTBUNTU_PATH/provision/gnome/configure/"*.sh; do
  [[ "$installer" == *"disable-ubuntu-extensions.sh" ]] && continue
  [[ "$installer" == *"keybindings.sh" ]] && continue
  [[ "$installer" == *"shell-extensions.sh" ]] && continue
  run_script "$installer"
done
# Extension installation already ran in the parent orchestrator while popups
# were visible. Skip it here so each extension is installed exactly once.
for installer in "$JUSTBUNTU_PATH/provision/gnome/install/"*.sh; do
  [[ "$installer" == *"gnome-shell-extensions.sh" ]] && continue
  run_script "$installer"
done

# Return to the real terminal before asking the reboot question. Normal
# installer output is redirected to the private log stream, but this choice
# must remain visible and interactive.
restore_tty
if justbuntu_confirm "Ready to reboot for all settings to take effect?" yes; then
  enable_logging
  sudo reboot || true
else
  printf '%s\n' 'Installation finished. Reboot skipped.'
  enable_logging
fi
