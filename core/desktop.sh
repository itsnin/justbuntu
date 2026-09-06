#!/bin/bash

# Keybindings first. Sets base shortcuts (Super+1-9 = workspaces).
# No user interaction, runs instantly.
run_script "$HOME/.local/share/justbuntu/configure/gnome/keybindings.sh"

# GNOME extensions already handled in the parent orchestrator before the
# unattended phase began (they have interactive popups requiring user attention).

# Run GNOME configuration scripts (keybindings already ran above)
for installer in "$HOME/.local/share/justbuntu/configure/gnome/"*.sh; do
  [[ "$installer" == *"keybindings.sh" ]] && continue
  run_script "$installer"
done
# Run GNOME-only software installs (Boxes, Sushi, Tweaks, Wayland scroll factor)
for installer in "$HOME/.local/share/justbuntu/install/gnome/"*.sh; do
  run_script "$installer"
done

# Logout to pick up changes
if gum confirm "Ready to reboot for all settings to take effect?"; then sudo reboot || true; fi
