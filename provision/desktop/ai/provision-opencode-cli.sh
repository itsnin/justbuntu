#!/bin/bash
# install OpenCode CLI
# requires LLM API keys to be configured after installation
# primary method: official install script
if curl -fsSL --retry 3 --retry-delay 5 https://opencode.ai/install | bash; then
  echo "opencode cli installed via official script. run 'opencode' to configure API keys."
else
  echo "opencode.ai install script failed, trying direct binary download from github releases..."
  # fallback: download binary directly from github releases
  BIN_URL=$(curl -fsSL --retry 2 "https://api.github.com/repos/anomalyco/opencode/releases/latest" | python3 -c "
import json, sys
assets = json.load(sys.stdin).get('assets', [])
for a in assets:
    name = a.get('name', '')
    if 'linux' in name.lower() and 'x64' in name.lower() and name.endswith(('.tar.gz', '')) and 'desktop' not in name.lower():
        print(a['browser_download_url'])
        sys.exit(0)
sys.exit(1)
" 2>/dev/null)
  if [ -n "$BIN_URL" ]; then
    (
      cd /tmp
      if curl -fsSL --retry 2 -o opencode-bin "$BIN_URL"; then
        chmod +x opencode-bin
        mkdir -p "$HOME/.local/bin"
        mv opencode-bin "$HOME/.local/bin/opencode"
        echo "opencode cli installed via github binary. run 'opencode' to configure API keys."
      else
        echo "opencode cli binary download also failed (continuing)"
      fi
    )
  else
    echo "opencode cli: could not find github release binary (continuing)"
  fi
fi
