#!/bin/bash
# Find the latest release with a Linux x86-64 .deb asset
# Asset naming has varied between releases so check multiple
DEB_URL=$(curl -fsSL --retry 2 "https://api.github.com/repos/localsend/localsend/releases?per_page=10" | python3 -c "
import json, sys, re
try:
    releases = json.load(sys.stdin)
except (json.JSONDecodeError, TypeError):
    sys.exit(0)
if not isinstance(releases, list):
    sys.exit(0)
patterns = [r'linux-x86-64\.deb$', r'linux_x86-64\.deb$', r'amd64\.deb$']
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
        for p in patterns:
            if re.search(p, name, re.IGNORECASE):
                url = asset.get('browser_download_url')
                if isinstance(url, str) and url:
                    print(url)
                    sys.exit(0)
                break
sys.exit(0)
 ") || DEB_URL=""

if [ -z "$DEB_URL" ]; then
  echo "warning: could not find a localsend .deb release"
  echo "skipping localsend installation"
  return 0
fi

# Run download and install in a subshell. Avoids changing parent working directory.
(
  TMP_DIR=$(mktemp -d) && cd "$TMP_DIR" || exit 1
  if wget -q -O localsend.deb "$DEB_URL"; then
    sudo apt install -y ./localsend.deb || echo "localsend install failed (continuing)"
    rm -rf "$TMP_DIR"
  else
    echo "localsend download failed (continuing)"
  fi
)
