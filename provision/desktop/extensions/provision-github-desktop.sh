#!/bin/bash
# install GitHub Desktop (shiftkey/desktop fork)
# query last 10 releases, iterate to find one with an amd64 .deb asset
DEB_URL=$(curl -fsSL --retry 2 "https://api.github.com/repos/shiftkey/desktop/releases?per_page=10" | python3 -c "
import json, sys
releases = json.load(sys.stdin)
for release in releases:
    if release.get('prerelease', False):
        continue
    for asset in release.get('assets', []):
        name = asset.get('name', '')
        if name.endswith('.deb') and 'amd64' in name.lower():
            print(asset['browser_download_url'])
            sys.exit(0)
sys.exit(1)
" 2>/dev/null)

if [ -z "$DEB_URL" ]; then
  echo "warning: could not find a github desktop .deb release"
  echo "skipping github desktop installation"
  return 0
fi

# download and install in a subshell
(
  cd /tmp
  if curl -fsSL --retry 2 -o github-desktop.deb "$DEB_URL"; then
    sudo apt install -y ./github-desktop.deb || echo "github desktop install failed (continuing)"
    rm -f github-desktop.deb
  else
    echo "github desktop download failed (continuing)"
  fi
)
