#!/bin/bash
# snapd choice first — fundamental system decision
SNAPD_OPTIONS=("Remove snapd" "Keep snapd")
DEFAULT_CHOICE="Remove snapd"
export JUSTBUNTU_SNAPD_CHOICE=$(gum choose "${SNAPD_OPTIONS[@]}" --selected "$DEFAULT_CHOICE" --height 3 --header "Ubuntu ships with snapd by default. Remove it?")

AVAILABLE_LANGUAGES=("Python" "Rust" "Go" "Node.js" "Java" "C/C++ Build Tools" "PostgreSQL" "Web Tools")
SELECTED_LANGUAGES="Python,Node.js"
export JUSTBUNTU_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 12 --header "Select development tools")
# github authentication — optional, runs gh auth login after github cli is installed
if gum confirm "Set up GitHub authentication? (runs gh auth login after GitHub CLI install)"; then
  export JUSTBUNTU_GITHUB_AUTH="true"
else
  export JUSTBUNTU_GITHUB_AUTH="false"
fi

# optional desktop apps only offered when running gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  # browsers first — web apps depend on this choice
  BROWSER_OPTIONS=("Chrome" "Brave Origin" "None")
  DEFAULT_BROWSER="Chrome"
  export JUSTBUNTU_FIRST_RUN_BROWSERS=$(gum choose "${BROWSER_OPTIONS[@]}" --no-limit --selected "$DEFAULT_BROWSER" --height 6 --header "Select browsers to install (multi-select)")

  AVAILABLE_OPTIONAL=("JetBrains Toolbox" "OBS Studio" "Spotify" "Slack" "Discord" "Web Apps")
  export JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS=$(gum choose "${AVAILABLE_OPTIONAL[@]}" --no-limit --height 10 --header "Select optional desktop applications")

  # if web apps selected, ask which specific ones
  if [[ "$JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS" == *"Web Apps"* ]]; then
    WEB_APP_OPTIONS=("ChatGPT" "Google Photos" "Google Keep" "YouTube" "Facebook" "Messenger" "Instagram" "Reddit")
    export JUSTBUNTU_FIRST_RUN_WEB_APPS=$(gum choose "${WEB_APP_OPTIONS[@]}" --no-limit --height 10 --header "Select specific web apps to install")
  fi

  # ai tools — separate category, optional. all require post-install authentication.
  AVAILABLE_AI=("Claude Desktop" "Claude Code CLI" "OpenCode CLI" "Antigravity CLI (Google)" "Codex CLI (OpenAI)")
  export JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS=$(gum choose "${AVAILABLE_AI[@]}" --no-limit --height 8 --header "Select AI tools (optional, all require account login after install)")

  # gnome extensions — requires accepting some confirmations during install
  if gum confirm "Install GNOME extensions? (requires accepting some confirmations during setup)"; then
    export JUSTBUNTU_INSTALL_EXTENSIONS="true"
  else
    export JUSTBUNTU_INSTALL_EXTENSIONS="false"
  fi
fi
