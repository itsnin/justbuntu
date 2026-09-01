#!/bin/bash
# install OpenCode CLI
# requires LLM API keys to be configured after installation
if curl -fsSL https://opencode.ai/install | bash; then
  echo "opencode cli installed. run 'opencode' to configure API keys."
else
  echo "opencode cli install failed (continuing)"
fi
