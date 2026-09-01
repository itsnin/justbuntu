#!/bin/bash
# install Google Antigravity CLI (agy)
# requires google account authentication after installation
if curl -fsSL https://antigravity.google/cli/install.sh | bash; then
  echo "antigravity cli installed. run 'agy' to authenticate and start."
else
  echo "antigravity cli install failed (continuing)"
fi
