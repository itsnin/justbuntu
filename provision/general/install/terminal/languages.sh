#!/bin/bash
# Language selection orchestrator. Respects JUSTBUNTU_FIRST_RUN_LANGUAGES env var
# or prompts interactively. Each language has its own install file.
AVAILABLE_LANGUAGES=("Python" "Rust" "Go" "Node.js" "Java" "C/C++ Build Tools" "PostgreSQL")

if [ -n "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" ]; then
  SELECTED="$JUSTBUNTU_FIRST_RUN_LANGUAGES"
else
  SELECTED_LANGUAGES="Python,Node.js"
  SELECTED=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 12 --header "Select development tools")
fi

export JUSTBUNTU_FIRST_RUN_LANGUAGES="$SELECTED"

TERM_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$TERM_DIR/programming-language/python.sh"
source "$TERM_DIR/programming-language/rust.sh"
source "$TERM_DIR/programming-language/go.sh"
source "$TERM_DIR/programming-language/nodejs.sh"
source "$TERM_DIR/programming-language/java.sh"
source "$TERM_DIR/programming-language/c-cpp.sh"
source "$TERM_DIR/database/postgresql.sh"
