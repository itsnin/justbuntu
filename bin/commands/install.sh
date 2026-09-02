#!/bin/bash
CHOICES=(
  "Dev Language      Install programming languages and tools"
  "JetBrains Toolbox Manage JetBrains IDEs"
  "OBS Studio        Record screencasts with inputs from display + webcam"
  "Spotify           Stream music"
  "Slack             Team communication and collaboration"
  "Discord           Voice, video and text chat"
  "GitHub Desktop    Git client with GUI and PR/code review"
  "Wayland Scroll Factor  Adjust two-finger scroll sensitivity for hypersensitive touchpads"
  "Claude Desktop    AI assistant with chat, code, and cowork"
  "Claude Code CLI   AI coding agent in your terminal (Anthropic)"
  "OpenCode CLI      AI coding agent in your terminal (Anomaly)"
  "Antigravity CLI   AI coding agent in your terminal (Google)"
  "Codex CLI         AI coding agent in your terminal (OpenAI)"
  "Web Apps          Install web apps with their own icon and shell"
  "> All             Re-run any of the default installers"
  "<< Back           "
)
CHOICE=$(gum choose "${CHOICES[@]}" --height 28 --header "Install additional components")
if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  # don't install anything
  echo ""
elif [[ "$CHOICE" == "> All"* ]]; then
  INSTALLER_FILE=$(gum file "$JUSTBUNTU_PATH/provision")
  [[ -n "$INSTALLER_FILE" ]] &&
    gum confirm "Run installer?" &&
    source "$INSTALLER_FILE" &&
    gum spin --spinner globe --title "Install completed!" -- sleep 3
else
  INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
  case "$INSTALLER" in
  "dev-language") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/terminal/provision-dev-tooling.sh" ;;
  "jetbrains-toolbox") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-jetbrains-toolbox.sh" ;;
  "obs-studio") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-obs-studio.sh" ;;
  "spotify") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-spotify.sh" ;;
  "slack") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-slack.sh" ;;
  "discord") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-discord.sh" ;;
  "github-desktop") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-github-desktop.sh" ;;
  "wayland-scroll-factor") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-wayland-scroll-factor.sh" ;;
  "claude-desktop") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/ai/provision-claude-desktop.sh" ;;
  "claude-code-cli") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/ai/provision-claude-code-cli.sh" ;;
  "opencode-cli") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/ai/provision-opencode-cli.sh" ;;
  "antigravity-cli") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/ai/provision-antigravity-cli.sh" ;;
  "codex-cli") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/ai/provision-codex-cli.sh" ;;
  "web-apps") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/desktop/extensions/provision-web-apps.sh" ;;
  esac
  if [[ -n "$INSTALLER_FILE" ]]; then
    source "$INSTALLER_FILE" && gum spin --spinner globe --title "Install completed!" -- sleep 3
  fi
fi
clear
source "$JUSTBUNTU_PATH/bin/justbuntu"
