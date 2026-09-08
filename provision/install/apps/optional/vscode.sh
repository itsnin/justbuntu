#!/bin/bash
# Install vs code via direct .deb
# The debconf line below is required or the .deb postinst prompts
# whether to add Microsoft's apt repo, which hangs an unattended script
if command -v code >/dev/null 2>&1; then
  echo "vs code already installed, skipping"
  return 0
fi
echo "==> installing vs code (direct .deb)"
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
TMP_DEB=$(mktemp)
trap 'rm -f "$TMP_DEB"' RETURN
if wget -q -O "$TMP_DEB" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"; then
  sudo apt-get install -y "$TMP_DEB" || echo "vs code install failed (continuing)"
else
  echo "vs code download failed (continuing)"
fi
