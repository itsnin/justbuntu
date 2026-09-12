#!/bin/bash
source "$JUSTBUNTU_PATH/lib/interactive.sh"

# Remove or keep snapd based on first-run preference. Prompts if running directly.
if [[ -n "${JUSTBUNTU_SNAPD_CHOICE:-}" ]]; then
  SNAPD_CHOICE="$JUSTBUNTU_SNAPD_CHOICE"
else
  SNAPD_OPTIONS=("Remove snapd" "Keep snapd")
  DEFAULT_CHOICE="Remove snapd"
  SNAPD_CHOICE=$(justbuntu_select "Ubuntu ships with snapd by default. Remove it?" "$DEFAULT_CHOICE" single "${SNAPD_OPTIONS[@]}")
fi

if [[ "$SNAPD_CHOICE" == "Remove snapd"* ]]; then
  # Hold, not just remove. Stops apt upgrade from pulling snapd back via ubuntu-server's recommends.
  echo "==> removing snapd"
  if command -v snap >/dev/null 2>&1 || dpkg -s snapd >/dev/null 2>&1; then
    sudo apt-get purge -y snapd
    sudo apt-mark hold snapd
    echo "successfully removed snaps"
  else
    echo "snapd is not installed"
  fi
  # Clean up orphans
  echo "==> autoremoving orphans"
  sudo apt-get autoremove -y --purge || echo "autoremove failed (continuing)"
fi
