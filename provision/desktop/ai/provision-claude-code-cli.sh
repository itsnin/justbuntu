#!/bin/bash
# install Claude Code CLI (Anthropic)
# requires browser authentication after installation
if curl -fsSL https://claude.ai/install.sh | bash; then
  echo "claude code cli installed. run 'claude' to authenticate and start."
else
  echo "claude code cli install failed (continuing)"
fi
