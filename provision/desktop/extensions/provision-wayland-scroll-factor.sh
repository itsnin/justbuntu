#!/bin/bash
# install wayland-scroll-factor — adjusts two-finger scroll sensitivity
# for users with hypersensitive touchpads on GNOME Wayland
# query last 10 releases, skip prereleases, find first non-dbgsym amd64 .deb
DEB_URL=$(curl -fsSL --retry 2 "https://api.github.com/repos/daniel-g-carrasco/wayland-scroll-factor/releases?per_page=10" | python3 -c "
import json, sys
releases = json.load(sys.stdin)
for release in releases:
    if release.get('prerelease', False):
        continue
    assets = release.get('assets', [])
    for a in assets:
        name = a.get('name', '')
        if name.endswith('.deb') and 'amd64' in name.lower() and 'dbgsym' not in name.lower():
            print(a['browser_download_url'])
            sys.exit(0)
sys.exit(1)
" 2>/dev/null)

if [ -z "$DEB_URL" ]; then
  echo "warning: could not find a wayland-scroll-factor .deb release"
  echo "skipping wayland-scroll-factor installation"
  return 0
fi

(
  cd /tmp
  if curl -fsSL --retry 2 -o wayland-scroll-factor.deb "$DEB_URL"; then
    sudo apt install -y ./wayland-scroll-factor.deb || echo "wayland-scroll-factor install failed (continuing)"
    rm -f wayland-scroll-factor.deb
  else
    echo "wayland-scroll-factor download failed (continuing)"
  fi
)
