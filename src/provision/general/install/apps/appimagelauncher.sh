#!/bin/bash
# Install AppImageLauncher — integrates AppImage files into the system
# Query last 10 releases, skip prereleases, find first amd64 .deb
# Prefer non-xenial assets. Bionic or plain work on newer Ubuntu.
DEB_URL=$(curl -fsSL --retry 2 "https://api.github.com/repos/TheAssassin/AppImageLauncher/releases?per_page=10" | python3 -c "
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
    candidates = [
        a for a in assets
        if isinstance(a, dict)
        and isinstance(a.get('name'), str)
        and a['name'].endswith('.deb')
        and 'amd64' in a['name'].lower()
    ]
    if not candidates:
        continue
    # Prefer non-xenial (bionic or plain) for newer Ubuntu
    non_xenial = [a for a in candidates if 'xenial' not in a['name'].lower()]
    chosen = non_xenial[0] if non_xenial else candidates[0]
    url = chosen.get('browser_download_url')
    if isinstance(url, str) and url:
        print(url)
        break
" 2>/dev/null) || DEB_URL=""

if [ -z "$DEB_URL" ]; then
  echo "warning: could not find an appimagelauncher .deb release"
  echo "skipping appimagelauncher installation"
  return 0
fi

# Download and install
(
  TMP_DIR=$(mktemp -d) && cd "$TMP_DIR" || exit 1
  if curl -fsSL --retry 2 -o appimagelauncher.deb "$DEB_URL"; then
    sudo apt install -y ./appimagelauncher.deb || echo "appimagelauncher install failed (continuing)"
    rm -rf "$TMP_DIR"
  else
    echo "appimagelauncher download failed (continuing)"
  fi
)
