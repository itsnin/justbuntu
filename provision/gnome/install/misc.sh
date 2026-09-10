#!/bin/bash
# Install GNOME-specific optional add-ons. Wayland scroll factor uses
# GNOME/mutter dconf and is not portable to other desktop environments.
if [[ -v JUSTBUNTU_FIRST_RUN_GNOME_EXTRAS ]]; then
  selected="$JUSTBUNTU_FIRST_RUN_GNOME_EXTRAS"
else
  GNOME_OPTIONAL=("Wayland Scroll Factor")
  selected=$(gum choose "${GNOME_OPTIONAL[@]}" --no-limit --height 4 --show-help=false --header "Space: select/deselect | Enter: confirm | GNOME add-ons")
fi
if [[ "$selected" == *"Wayland Scroll Factor"* ]]; then
  source "$JUSTBUNTU_PATH/provision/gnome/install/misc/wayland-scroll-factor.sh"
fi
