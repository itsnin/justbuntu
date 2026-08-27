#!/bin/bash
cd /tmp

# find the latest release with a linux x86_64 tar.gz asset
TAR_URL=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases?per_page=10" | python3 -c "
import json, sys, re
releases = json.load(sys.stdin)
patterns = [r'Linux_x86_64\.tar\.gz$', r'linux_amd64\.tar\.gz$', r'x86_64\.tar\.gz$']
for release in releases:
    for asset in release.get('assets', []):
        name = asset.get('name', '')
        for p in patterns:
            if re.search(p, name):
                print(asset['browser_download_url'])
                sys.exit(0)
sys.exit(1)
")

if [ -z "$TAR_URL" ]; then
  echo "warning: could not find a lazydocker release asset"
  echo "skipping lazydocker installation"
  cd -
  return 0
fi

curl -sLo lazydocker.tar.gz "$TAR_URL"
tar -xf lazydocker.tar.gz lazydocker
sudo install lazydocker /usr/local/bin
rm lazydocker.tar.gz lazydocker
cd -
