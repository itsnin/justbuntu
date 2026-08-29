#!/bin/bash
# obsidian is a multi-platform note taking application. see https://obsidian.md
cd /tmp

# find the latest release that actually has a .deb asset
# some releases are mobile-only and only ship an apk
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
  cd -
  return 0
fi

wget -O obsidian.deb "$DEB_URL"
sudo apt install -y ./obsidian.deb
rm obsidian.deb
cd -
