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

for extension in "${UBUNTU_EXTENSIONS[@]}"; do
  gnome-extensions disable "$extension" 2>/dev/null || true
done
