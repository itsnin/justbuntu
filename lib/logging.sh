#!/bin/bash
# Public logging facade. Implementation is organized by responsibility.

if [[ "${JUSTBUNTU_LOGGING_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_LOGGING_LOADED=true

JUSTBUNTU_LOGGING_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/logging" && pwd)
source "$JUSTBUNTU_LOGGING_DIR/core.sh"
source "$JUSTBUNTU_LOGGING_DIR/session.sh"
source "$JUSTBUNTU_LOGGING_DIR/execution.sh"
