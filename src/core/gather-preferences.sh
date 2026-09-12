#!/bin/bash
source "$JUSTBUNTU_PATH/lib/interactive.sh"

# Snapd choice first. It's the most fundamental system decision.
SNAPD_OPTIONS=("Remove snapd" "Keep snapd")
DEFAULT_CHOICE="Remove snapd"
JUSTBUNTU_SNAPD_CHOICE=$(justbuntu_select "Ubuntu ships with snapd by default. Remove it?" "$DEFAULT_CHOICE" single "${SNAPD_OPTIONS[@]}")
export JUSTBUNTU_SNAPD_CHOICE
AVAILABLE_LANGUAGES=("Python" "Rust" "Go" "Node.js" "Java" "C/C++ Build Tools" "PostgreSQL")
SELECTED_LANGUAGES="Python,Rust,Go,Node.js,Java,C/C++ Build Tools,PostgreSQL"
JUSTBUNTU_FIRST_RUN_LANGUAGES=$(justbuntu_select "Select development tools" "$SELECTED_LANGUAGES" multiple "${AVAILABLE_LANGUAGES[@]}")
export JUSTBUNTU_FIRST_RUN_LANGUAGES
# Browsers. Cross-desktop — Chrome and Brave work on any DE.
# Web apps depend on having a Chromium-based browser installed.
BROWSER_OPTIONS=("Chrome" "Brave Origin")
DEFAULT_BROWSER="Chrome"
JUSTBUNTU_FIRST_RUN_BROWSERS=$(justbuntu_select "Select browsers" "$DEFAULT_BROWSER" multiple "${BROWSER_OPTIONS[@]}")
export JUSTBUNTU_FIRST_RUN_BROWSERS
# Optional applications are the installers kept under apps/optional/.
# Web Apps is a separate optional feature with its own installer.
AVAILABLE_OPTIONAL=("JetBrains Toolbox" "Slack" "Discord" "GitHub Desktop" "VS Code" "Obsidian" "Element" "Web Apps")
JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS=$(justbuntu_select "Optional applications" "" multiple "${AVAILABLE_OPTIONAL[@]}")
export JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS
# If web apps selected, ask which specific ones.
if [[ "$JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS" == *"Web Apps"* ]]; then
  WEB_APP_OPTIONS=("ChatGPT" "Google Drive" "Google Photos" "Google Keep" "YouTube" "Facebook" "Messenger" "Instagram" "Reddit" "WhatsApp")
  JUSTBUNTU_FIRST_RUN_WEB_APPS=$(justbuntu_select "Select web apps" "" multiple "${WEB_APP_OPTIONS[@]}")
  export JUSTBUNTU_FIRST_RUN_WEB_APPS
fi
# AI tools. Cross-desktop — CLIs work anywhere, Claude Desktop just needs X11/Wayland.
AVAILABLE_AI=("Claude Desktop" "Claude Code CLI" "OpenCode CLI" "Antigravity CLI (Google)" "Codex CLI (OpenAI)")
JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS=$(justbuntu_select "Select AI tools" "" multiple "${AVAILABLE_AI[@]}")
export JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS
# GNOME-specific questions only offered when running GNOME
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  # GNOME-specific optional add-ons
  GNOME_OPTIONAL=("Wayland Scroll Factor")
  JUSTBUNTU_FIRST_RUN_GNOME_EXTRAS=$(justbuntu_select "GNOME add-ons" "" multiple "${GNOME_OPTIONAL[@]}")
  export JUSTBUNTU_FIRST_RUN_GNOME_EXTRAS
  # GNOME extensions. Requires accepting some confirmations during install.
  if justbuntu_confirm "Install GNOME extensions? (requires accepting some confirmations during setup)" yes; then
    export JUSTBUNTU_INSTALL_EXTENSIONS="true"
  else
    export JUSTBUNTU_INSTALL_EXTENSIONS="false"
  fi
fi

# Collect Git identity and optional Git HTTPS credentials after all first-run
# choices and before terminal provisioning begins.
GIT_NAME_DEFAULT=""
GIT_EMAIL_DEFAULT=""
if command -v git >/dev/null 2>&1; then
  GIT_NAME_DEFAULT=$(git config --global user.name 2>/dev/null || true)
  GIT_EMAIL_DEFAULT=$(git config --global user.email 2>/dev/null || true)
fi
if [[ -z "$GIT_NAME_DEFAULT" ]] && command -v getent >/dev/null 2>&1; then
  GIT_NAME_DEFAULT=$(getent passwd "${USER:-}" | cut -d ':' -f 5 | cut -d ',' -f 1 || true)
fi
if [[ -z "$GIT_NAME_DEFAULT" ]]; then
  GIT_NAME_DEFAULT="${USER:-$(id -un 2>/dev/null || printf 'user')}"
fi
JUSTBUNTU_GIT_USER_NAME=$(justbuntu_input "Git identity: full name (leave empty to skip)" "$GIT_NAME_DEFAULT" false || true)
JUSTBUNTU_GIT_USER_EMAIL=$(justbuntu_input "Git identity: email address (leave empty to skip)" "$GIT_EMAIL_DEFAULT" false || true)
JUSTBUNTU_GIT_CREDENTIAL_USERNAME=$(justbuntu_input "Git HTTPS username (leave empty to skip)" "" false || true)
JUSTBUNTU_GIT_CREDENTIAL_SECRET=$(justbuntu_input "Git HTTPS password or token (leave empty to skip)" "" true || true)
export JUSTBUNTU_GIT_USER_NAME JUSTBUNTU_GIT_USER_EMAIL \
  JUSTBUNTU_GIT_CREDENTIAL_USERNAME JUSTBUNTU_GIT_CREDENTIAL_SECRET
