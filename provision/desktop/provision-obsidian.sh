#!/bin/bash
# Obsidian is a multi-platform note taking application. See https://obsidian.md
# Find the latest release that actually has a .deb asset
# Some releases are mobile-only and only ship an APK
RELEASES=$(curl -s "https://api.github.com/repos/obsidianmd/obsidian-releases/releases?per_page=10")
DEB_URL=$(echo "$RELEASES" | python3 -c "
import json, sys
releases = json.load(sys.stdin)
for release in releases:
    for asset in release.get('assets', []):
        name = asset.get('name', '')
        if name.endswith('_amd64.deb'):
            print(asset['browser_download_url'])
            sys.exit(0)
sys.exit(1)
")

if [ -z "$DEB_URL" ]; then
  echo "warning: could not find a .deb release for obsidian"
  echo "skipping obsidian installation"
  return 0
fi

# Run download and install in a subshell. Avoids changing parent working directory.
(
  cd /tmp || exit 1
  if wget -q -O obsidian.deb "$DEB_URL"; then
    sudo apt install -y ./obsidian.deb || echo "obsidian install failed (continuing)"
    rm -f obsidian.deb
  else
    echo "obsidian download failed (continuing)"
  fi
)
