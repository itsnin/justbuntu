#!/bin/bash
# install ai tools. separate category from optional apps. user chooses.
# all cli tools require browser authentication after installation.
if [[ -v JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS ]]; then
  selected="$JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS"
else
  AI_OPTIONS=("Claude Desktop" "Claude Code CLI" "OpenCode CLI" "Antigravity CLI (Google)" "Codex CLI (OpenAI)")
  selected=$(gum choose "${AI_OPTIONS[@]}" --no-limit --height 8 --header "Select AI tools (optional, all require account login after install)")
fi
if [[ "$selected" == *"Claude Desktop"* ]]; then
  source "$JUSTBUNTU_PATH/provision/desktop/ai/provision-claude-desktop.sh"
fi
if [[ "$selected" == *"Claude Code CLI"* ]]; then
  source "$JUSTBUNTU_PATH/provision/desktop/ai/provision-claude-code-cli.sh"
fi
if [[ "$selected" == *"OpenCode CLI"* ]]; then
  source "$JUSTBUNTU_PATH/provision/desktop/ai/provision-opencode-cli.sh"
fi
if [[ "$selected" == *"Antigravity CLI"* ]]; then
  source "$JUSTBUNTU_PATH/provision/desktop/ai/provision-antigravity-cli.sh"
fi
if [[ "$selected" == *"Codex CLI"* ]]; then
  source "$JUSTBUNTU_PATH/provision/desktop/ai/provision-codex-cli.sh"
fi
