#!/bin/bash
# Install OpenAI Codex CLI
# Requires ChatGPT/OpenAI account authentication after installation.
if curl -fsSL --retry 3 --retry-delay 5 https://chatgpt.com/codex/install.sh | sh; then
  echo "codex cli installed. run 'codex' to authenticate and start."
else
  echo "codex cli install failed (continuing)"
fi
