#!/bin/bash
# Snapd choice first. It's the most fundamental system decision.
SNAPD_OPTIONS=("Remove snapd" "Keep snapd")
DEFAULT_CHOICE="Remove snapd"
JUSTBUNTU_SNAPD_CHOICE=$(gum choose "${SNAPD_OPTIONS[@]}" --selected "$DEFAULT_CHOICE" --height 3 --header "Ubuntu ships with snapd by default. Remove it?")
export JUSTBUNTU_SNAPD_CHOICE
AVAILABLE_LANGUAGES=("Python" "Rust" "Go" "Node.js" "Java" "C/C++ Build Tools" "PostgreSQL" "Web Tools")
SELECTED_LANGUAGES="Python,Rust,Go,Node.js,Java,C/C++ Build Tools,PostgreSQL,Web Tools"
JUSTBUNTU_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 12 --header "Select development tools")
export JUSTBUNTU_FIRST_RUN_LANGUAGES
# Browsers. Cross-desktop — Chrome and Brave work on any DE.
# Web apps depend on having a Chromium-based browser installed.
BROWSER_OPTIONS=("Chrome" "Brave Origin")
DEFAULT_BROWSER="Chrome"
JUSTBUNTU_FIRST_RUN_BROWSERS=$(gum choose "${BROWSER_OPTIONS[@]}" --no-limit --selected "$DEFAULT_BROWSER" --height 6 --header "Select browsers to install (multi-select)")
export JUSTBUNTU_FIRST_RUN_BROWSERS
# Optional cross-desktop applications. Run regardless of desktop environment.
AVAILABLE_OPTIONAL=("JetBrains Toolbox" "OBS Studio" "Spotify" "Slack" "Discord" "GitHub Desktop" "VLC" "VS Code" "Obsidian" "LocalSend" "Element" "AppImageLauncher" "Ghostty" "Web Apps")
JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS=$(gum choose "${AVAILABLE_OPTIONAL[@]}" --no-limit --height 15 --header "Select optional applications")
export JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS
# If web apps selected, ask which specific ones.
if [[ "$JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS" == *"Web Apps"* ]]; then
  WEB_APP_OPTIONS=("ChatGPT" "Google Drive" "Google Photos" "Google Keep" "YouTube" "Facebook" "Messenger" "Instagram" "Reddit")
  JUSTBUNTU_FIRST_RUN_WEB_APPS=$(gum choose "${WEB_APP_OPTIONS[@]}" --no-limit --height 10 --header "Select specific web apps to install")
  export JUSTBUNTU_FIRST_RUN_WEB_APPS
fi
# AI tools. Cross-desktop — CLIs work anywhere, Claude Desktop just needs X11/Wayland.
AVAILABLE_AI=("Claude Desktop" "Claude Code CLI" "OpenCode CLI" "Antigravity CLI (Google)" "Codex CLI (OpenAI)")
JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS=$(gum choose "${AVAILABLE_AI[@]}" --no-limit --height 8 --header "Select AI tools (optional, all require account login after install)")
export JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS
# GNOME-specific questions only offered when running GNOME
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  # GNOME-specific optional add-ons
  GNOME_OPTIONAL=("Wayland Scroll Factor")
  JUSTBUNTU_FIRST_RUN_GNOME_EXTRAS=$(gum choose "${GNOME_OPTIONAL[@]}" --no-limit --height 4 --header "Select GNOME-specific add-ons")
  export JUSTBUNTU_FIRST_RUN_GNOME_EXTRAS
  # GNOME extensions. Requires accepting some confirmations during install.
  if gum confirm "Install GNOME extensions? (requires accepting some confirmations during setup)"; then
    export JUSTBUNTU_INSTALL_EXTENSIONS="true"
  else
    export JUSTBUNTU_INSTALL_EXTENSIONS="false"
  fi
fi
