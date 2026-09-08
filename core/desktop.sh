#!/bin/bash

# Keybindings first. Sets base shortcuts (Super+1-9 = workspaces).
# No user interaction, runs instantly.
run_script "$HOME/.local/share/justbuntu/provision/gnome/configure/keybindings.sh"

# GNOME extensions already handled in the parent orchestrator before the
# unattended phase began (they have interactive popups requiring user attention).

# Run GNOME configuration scripts (keybindings already ran above)
for installer in "$HOME/.local/share/justbuntu/provision/gnome/configure/"*.sh; do
  [[ "$installer" == *"keybindings.sh" ]] && continue
  run_script "$installer"
done
# Run GNOME-only software installs (Boxes, Sushi, Tweaks, Wayland scroll factor)
# shell-extensions.sh lives at parent level (gnome-shell-extensions.sh) and runs
# in the parent orchestrator before this subshell — interactive popups need user.
for installer in "$HOME/.local/share/justbuntu/provision/gnome/install/"*.sh; do
  run_script "$installer"
done

# Logout to pick up changes
if gum confirm "Ready to reboot for all settings to take effect?"; then sudo reboot || true; fi
