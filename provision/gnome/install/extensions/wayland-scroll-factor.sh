#!/bin/bash
# Install wayland-scroll-factor. GNOME/Wayland touchpad scroll speed tuner.
# Query last 10 releases, skip prereleases, find first amd64 .deb.
# Uses mktemp -d to avoid /tmp races.
(
  TMP_DIR=$(mktemp -d)
  cd "$TMP_DIR" || exit 1
  DEB_URL=$(curl -fsSL --retry 2 "https://api.github.com/repos/daniel-g-carrasco/wayland-scroll-factor/releases?per_page=10" | python3 -c "
import json, sys
releases = json.load(sys.stdin)
for release in releases:
    if release.get('prerelease', False):
        continue
    for asset in release.get('assets', []):
        name = asset.get('name', '')
        if name.endswith('_amd64.deb') or (name.endswith('.deb') and 'amd64' in name.lower()):
            print(asset.get('browser_download_url', ''))
            sys.exit(0)
sys.exit(1)
" 2>/dev/null)
  if [ -z "$DEB_URL" ]; then
    echo "warning: could not find a wayland-scroll-factor .deb release"
    echo "skipping wayland-scroll-factor installation"
    rm -rf "$TMP_DIR"
    exit 0
  fi
  if curl -fsSL --retry 2 "$DEB_URL" -o wayland-scroll-factor.deb; then
    sudo apt-get install -y ./wayland-scroll-factor.deb || echo "wayland-scroll-factor install failed (continuing)"
  else
    echo "wayland-scroll-factor download failed (continuing)"
  fi
  rm -rf "$TMP_DIR"
)
