#!/bin/bash
# install vs code via direct .deb
# the debconf line below is required or the .deb postinst prompts
# whether to add microsoft's apt repo, which hangs an unattended script
echo "==> installing vs code (direct .deb)"
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
if wget -q -O /tmp/vscode-stable.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"; then
  sudo apt-get install -y /tmp/vscode-stable.deb || echo "vs code install failed (continuing)"
  rm -f /tmp/vscode-stable.deb
else
  echo "vs code download failed (continuing)"
fi
