#!/bin/bash
# Install wayland-scroll-factor. GNOME/Wayland touchpad scroll speed tuner.
# Downloads latest .deb from GitHub releases using mktemp -d to avoid /tmp races.
(
  TMP_DIR=$(mktemp -d)
  cd "$TMP_DIR" || exit 1
  DEB_URL=$(curl -fsSL --retry 2 "https://api.github.com/repos/daniel-g-carrasco/wayland-scroll-factor/releases/latest" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for asset in data.get('assets', []):
    name = asset.get('name', '')
    if name.endswith('_amd64.deb'):
        print(asset.get('browser_download_url', ''))
        break
" 2>/dev/null)
  if [ -z "$DEB_URL" ]; then
    echo "warning: could not determine latest wayland-scroll-factor download url"
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
