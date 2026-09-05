#!/bin/bash
# Find the latest release with a Linux x86-64 .deb asset
# Asset naming has varied between releases so check multiple
DEB_URL=$(curl -s "https://api.github.com/repos/localsend/localsend/releases?per_page=10" | python3 -c "
import json, sys, re
releases = json.load(sys.stdin)
patterns = [r'linux-x86-64\.deb$', r'linux_x86-64\.deb$', r'amd64\.deb$']
for release in releases:
    for asset in release.get('assets', []):
        name = asset.get('name', '')
        for p in patterns:
            if re.search(p, name, re.IGNORECASE):
                print(asset['browser_download_url'])
                sys.exit(0)
sys.exit(1)
")

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
