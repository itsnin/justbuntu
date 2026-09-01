#!/bin/bash
# install OpenAI Codex CLI
# requires chatgpt/openai account authentication after installation
if curl -fsSL --retry 3 --retry-delay 5 https://chatgpt.com/codex/install.sh | sh; then
  echo "codex cli installed. run 'codex' to authenticate and start."
else
  echo "codex cli install failed (continuing)"
fi
