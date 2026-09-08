#!/bin/bash
# Language selection orchestrator. Respects JUSTBUNTU_FIRST_RUN_LANGUAGES env var
# or prompts interactively. Each language has its own install file.
AVAILABLE_LANGUAGES=("Python" "Rust" "Go" "Node.js" "Java" "C/C++ Build Tools" "PostgreSQL" "Web Tools")

if [ -n "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" ]; then
  SELECTED="$JUSTBUNTU_FIRST_RUN_LANGUAGES"
else
  SELECTED_LANGUAGES="Python,Node.js"
  SELECTED=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 12 --header "Select development tools")
fi

export JUSTBUNTU_FIRST_RUN_LANGUAGES="$SELECTED"

TERM_DIR="$(dirname "$0")"
source "$TERM_DIR/common-libs.inc.sh"
source "$TERM_DIR/python.inc.sh"
source "$TERM_DIR/rust.inc.sh"
source "$TERM_DIR/go.inc.sh"
source "$TERM_DIR/nodejs.inc.sh"
source "$TERM_DIR/java.inc.sh"
source "$TERM_DIR/c-cpp.inc.sh"
source "$TERM_DIR/postgresql.inc.sh"
source "$TERM_DIR/web-tools.inc.sh"
