#!/bin/bash
# remove or keep snapd based on first-run preference (or prompt if running directly)
if [[ -n "${JUSTBUNTU_SNAPD_CHOICE:-}" ]]; then
  SNAPD_CHOICE="$JUSTBUNTU_SNAPD_CHOICE"
else
  SNAPD_OPTIONS=("Remove snapd" "Keep snapd")
  DEFAULT_CHOICE="Remove snapd"
  SNAPD_CHOICE=$(gum choose "${SNAPD_OPTIONS[@]}" --selected "$DEFAULT_CHOICE" --height 3 --header "Ubuntu ships with snapd by default. Remove it?")
fi

if [[ "$SNAPD_CHOICE" == "Remove snapd"* ]]; then
  # hold not just remove, so apt upgrade cant pull snapd back via ubuntu-server's recommends
  echo "==> removing snapd"
  if command -v snap >/dev/null 2>&1 || dpkg -s snapd >/dev/null 2>&1; then
    sudo apt-get remove -y --purge snapd
    sudo apt-mark hold snapd
    echo "successfully removed snaps"
  else
    echo "snapd is not installed"
  fi
  # clean up orphans
  echo "==> autoremoving orphans"
  sudo apt-get autoremove -y --purge || echo "autoremove failed (continuing)"
fi
