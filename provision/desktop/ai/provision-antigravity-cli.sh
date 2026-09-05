#!/bin/bash
# Install Google Antigravity CLI (agy)
# Requires Google account authentication after installation.
if curl -fsSL --retry 3 --retry-delay 5 https://antigravity.google/cli/install.sh | bash; then
  echo "antigravity cli installed. run 'agy' to authenticate and start."
else
  echo "antigravity cli install failed (continuing)"
fi
