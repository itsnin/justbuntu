#!/bin/bash
source "$JUSTBUNTU_PATH/lib/interactive.sh"

CHOICES=(
  "Browsers          Install Chrome or Brave web browser"
  "Ghostty           Modern GPU-accelerated terminal emulator"
  "VLC               Media player"
  "VS Code           Code editor"
  "Obsidian          Markdown notes and knowledge base"
  "LocalSend         Cross-platform file transfer"
  "Element           Matrix chat client"
  "AppImageLauncher  Integrate AppImage files into system"
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
CHOICE=$(justbuntu_select "Install additional components" "" single "${CHOICES[@]}")
if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  # Don't install anything
  echo ""
elif [[ "$CHOICE" == "> All"* ]]; then
  INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/apps.sh"
  justbuntu_confirm "Run all application installers?" yes && source "$INSTALLER_FILE"
else
  INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
  case "$INSTALLER" in
  "browsers") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/browsers.sh" ;;
  "ghostty") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/ghostty.sh" ;;
  "vlc") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/vlc.sh" ;;
  "vs-code") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/optional/vscode.sh" ;;
  "obsidian") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/optional/obsidian.sh" ;;
  "localsend") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/localsend.sh" ;;
  "element") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/optional/element.sh" ;;
  "appimagelauncher") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/appimagelauncher.sh" ;;
  "dev-language") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/terminal/languages.sh" ;;
  "jetbrains-toolbox") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/optional/jetbrains-toolbox.sh" ;;
  "obs-studio") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/obs-studio.sh" ;;
  "spotify") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/spotify.sh" ;;
  "slack") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/optional/slack.sh" ;;
  "discord") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/optional/discord.sh" ;;
  "github-desktop") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/optional/github-desktop.sh" ;;
  "wayland-scroll-factor") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/gnome/install/misc/wayland-scroll-factor.sh" ;;
  "claude-desktop") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/ai/claude-desktop.sh" ;;
  "claude-code-cli") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/ai/claude-code-cli.sh" ;;
  "opencode-cli") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/ai/opencode-cli.sh" ;;
  "antigravity-cli") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/ai/antigravity-cli.sh" ;;
  "codex-cli") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/ai/codex-cli.sh" ;;
  "web-apps") INSTALLER_FILE="$JUSTBUNTU_PATH/provision/general/install/apps/web-apps.sh" ;;
  esac
  if [[ -n "$INSTALLER_FILE" ]]; then
    justbuntu_confirm "Run $(basename "$INSTALLER_FILE")?" yes && source "$INSTALLER_FILE"
  fi
fi
clear
source "$JUSTBUNTU_ROOT/bin/justbuntu"
