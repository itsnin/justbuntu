#!/bin/bash
# Snapd choice first. It's the most fundamental system decision.
SNAPD_OPTIONS=("Remove snapd" "Keep snapd")
DEFAULT_CHOICE="Remove snapd"
JUSTBUNTU_SNAPD_CHOICE=$(gum choose "${SNAPD_OPTIONS[@]}" --selected "$DEFAULT_CHOICE" --height 3 --header "Ubuntu ships with snapd by default. Remove it?")
export JUSTBUNTU_SNAPD_CHOICE
AVAILABLE_LANGUAGES=("Python" "Rust" "Go" "Node.js" "Java" "C/C++ Build Tools" "PostgreSQL")
SELECTED_LANGUAGES="Python,Rust,Go,Node.js,Java,C/C++ Build Tools,PostgreSQL"
JUSTBUNTU_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 12 --header "Space: select/deselect | Enter: confirm | Select development tools")
export JUSTBUNTU_FIRST_RUN_LANGUAGES
# Browsers. Cross-desktop — Chrome and Brave work on any DE.
# Web apps depend on having a Chromium-based browser installed.
BROWSER_OPTIONS=("Chrome" "Brave Origin")
DEFAULT_BROWSER="Chrome"
JUSTBUNTU_FIRST_RUN_BROWSERS=$(gum choose "${BROWSER_OPTIONS[@]}" --no-limit --selected "$DEFAULT_BROWSER" --height 6 --header "Space: select/deselect | Enter: confirm | Select browsers")
export JUSTBUNTU_FIRST_RUN_BROWSERS
# Optional applications are the installers kept under apps/optional/.
# Web Apps is a separate optional feature with its own installer.
AVAILABLE_OPTIONAL=("JetBrains Toolbox" "Slack" "Discord" "GitHub Desktop" "VS Code" "Obsidian" "Element" "Web Apps")
JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS=$(gum choose "${AVAILABLE_OPTIONAL[@]}" --no-limit --height 15 --header "Space: select/deselect | Enter: confirm | Optional applications")
export JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS
# If web apps selected, ask which specific ones.
if [[ "$JUSTBUNTU_FIRST_RUN_OPTIONAL_APPS" == *"Web Apps"* ]]; then
  WEB_APP_OPTIONS=("ChatGPT" "Google Drive" "Google Photos" "Google Keep" "YouTube" "Facebook" "Messenger" "Instagram" "Reddit" "WhatsApp")
  JUSTBUNTU_FIRST_RUN_WEB_APPS=$(gum choose "${WEB_APP_OPTIONS[@]}" --no-limit --height 10 --header "Space: select/deselect | Enter: confirm | Select web apps")
  export JUSTBUNTU_FIRST_RUN_WEB_APPS
fi
# AI tools. Cross-desktop — CLIs work anywhere, Claude Desktop just needs X11/Wayland.
AVAILABLE_AI=("Claude Desktop" "Claude Code CLI" "OpenCode CLI" "Antigravity CLI (Google)" "Codex CLI (OpenAI)")
JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS=$(gum choose "${AVAILABLE_AI[@]}" --no-limit --height 8 --header "Space: select/deselect | Enter: confirm | Select AI tools")
export JUSTBUNTU_FIRST_RUN_AI_ASSISTANTS
# GNOME-specific questions only offered when running GNOME
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  # GNOME-specific optional add-ons
  GNOME_OPTIONAL=("Wayland Scroll Factor")
  JUSTBUNTU_FIRST_RUN_GNOME_EXTRAS=$(gum choose "${GNOME_OPTIONAL[@]}" --no-limit --height 4 --header "Space: select/deselect | Enter: confirm | GNOME add-ons")
  export JUSTBUNTU_FIRST_RUN_GNOME_EXTRAS
  # GNOME extensions. Requires accepting some confirmations during install.
  if gum confirm "Install GNOME extensions? (requires accepting some confirmations during setup)"; then
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
JUSTBUNTU_GIT_USER_NAME=$(gum input \
  --placeholder "Enter full name (leave empty to skip)" \
  --value "$GIT_NAME_DEFAULT" --prompt "Name> " --header "Git identity setup" || true)
JUSTBUNTU_GIT_USER_EMAIL=$(gum input \
  --placeholder "Enter email address (leave empty to skip)" \
  --value "$GIT_EMAIL_DEFAULT" --prompt "Email> " --header "Git identity setup" || true)
JUSTBUNTU_GIT_CREDENTIAL_USERNAME=$(gum input \
  --placeholder "Git username (leave empty to skip)" \
  --prompt "Git username> " --header "Git HTTPS authentication setup" || true)
JUSTBUNTU_GIT_CREDENTIAL_SECRET=$(gum input --password \
  --placeholder "Git password or personal access token (leave empty to skip)" \
  --prompt "Git password/token> " \
  --header "Git HTTPS authentication setup" || true)
export JUSTBUNTU_GIT_USER_NAME JUSTBUNTU_GIT_USER_EMAIL \
  JUSTBUNTU_GIT_CREDENTIAL_USERNAME JUSTBUNTU_GIT_CREDENTIAL_SECRET
