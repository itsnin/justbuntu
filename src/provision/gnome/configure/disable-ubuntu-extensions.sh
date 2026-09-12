#!/bin/bash
set -euo pipefail

# Disable Ubuntu's bundled extensions before installing replacements.
UBUNTU_EXTENSIONS=(
  "tiling-assistant@ubuntu.com"
  "ubuntu-appindicators@ubuntu.com"
  "ubuntu-dock@ubuntu.com"
  "ding@rastersoft.com"
  "snapd-prompting@canonical.com"
  "snapd-search-provider@canonical.com"
)

remove_extension_from_list() {
  local key="$1"
  local extension="$2"
  local current quoted

  if ! current=$(gsettings get org.gnome.shell "$key" 2>/dev/null); then
    return 1
  fi
  current="${current#@as }"
  quoted="'$extension'"
  current="${current//"$quoted, "/}"
  current="${current//", $quoted"/}"
  current="${current//"$quoted"/}"
  gsettings set org.gnome.shell "$key" "$current" >/dev/null
}

add_extension_to_list() {
  local key="$1"
  local extension="$2"
  local current quoted

  if ! current=$(gsettings get org.gnome.shell "$key" 2>/dev/null); then
    return 1
  fi
  current="${current#@as }"
  quoted="'$extension'"
  if [[ "$current" == *"$quoted"* ]]; then
    return 0
  fi
  if [[ "$current" == "[]" ]]; then
    current="[$quoted]"
  else
    current="${current%]}, $quoted]"
  fi
  gsettings set org.gnome.shell "$key" "$current" >/dev/null
}

disable_extension() {
  local extension="$1"

  if ! gnome-extensions disable "$extension"; then
    printf 'warning: gnome-extensions could not disable %s; applying dconf fallback\n' "$extension" >&2
  fi
  if ! remove_extension_from_list enabled-extensions "$extension"; then
    printf 'warning: could not remove %s from enabled GNOME extensions\n' "$extension" >&2
  fi
  if ! add_extension_to_list disabled-extensions "$extension"; then
    printf 'warning: could not add %s to disabled GNOME extensions\n' "$extension" >&2
  fi
}

for extension in "${UBUNTU_EXTENSIONS[@]}"; do
  disable_extension "$extension"
done
