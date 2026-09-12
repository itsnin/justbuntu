#!/bin/bash
# Install GitHub Desktop (shiftkey/desktop fork)
# Query last 10 releases, iterate to find one with an amd64 .deb asset
DEB_URL=$(curl -fsSL --retry 2 "https://api.github.com/repos/shiftkey/desktop/releases?per_page=10" | python3 -c "
import json, sys
try:
    releases = json.load(sys.stdin)
except (json.JSONDecodeError, TypeError):
    sys.exit(0)
if not isinstance(releases, list):
    sys.exit(0)
for release in releases:
    if not isinstance(release, dict):
        continue
    if release.get('prerelease', False):
        continue
    assets = release.get('assets', [])
    if not isinstance(assets, list):
        continue
    for asset in assets:
        if not isinstance(asset, dict) or not isinstance(asset.get('name'), str):
            continue
        name = asset.get('name', '')
        if name.endswith('.deb') and 'amd64' in name.lower():
            url = asset.get('browser_download_url')
            if isinstance(url, str) and url:
                print(url)
                sys.exit(0)
sys.exit(0)
" 2>/dev/null) || DEB_URL=""

if [ -z "$DEB_URL" ]; then
  echo "warning: could not find a github desktop .deb release"
  echo "skipping github desktop installation"
  return 0
fi

# Download and install in a subshell
(
  TMP_DIR=$(mktemp -d) && cd "$TMP_DIR" || exit 1
  if curl -fsSL --retry 2 -o github-desktop.deb "$DEB_URL"; then
    sudo apt install -y ./github-desktop.deb || echo "github desktop install failed (continuing)"
    rm -rf "$TMP_DIR"
  else
    echo "github desktop download failed (continuing)"
  fi
)
