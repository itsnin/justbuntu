#!/bin/bash
source "$JUSTBUNTU_PATH/lib/interactive.sh"

# Language selection orchestrator. Respects JUSTBUNTU_FIRST_RUN_LANGUAGES env var
# or prompts interactively. Each language has its own install file.
AVAILABLE_LANGUAGES=("Python" "Rust" "Go" "Node.js" "Java" "C/C++ Build Tools" "PostgreSQL")

if [ -n "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" ]; then
  SELECTED="$JUSTBUNTU_FIRST_RUN_LANGUAGES"
else
  SELECTED_LANGUAGES="Python,Node.js"
  SELECTED=$(justbuntu_select "Development tools" "$SELECTED_LANGUAGES" multiple "${AVAILABLE_LANGUAGES[@]}")
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
