#!/bin/bash
# Public failure-handling facade. Implementation is organized by responsibility.

if [[ "${JUSTBUNTU_ERRORS_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_ERRORS_LOADED=true

JUSTBUNTU_LIB_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if ! declare -F log_error >/dev/null 2>&1; then
  source "$JUSTBUNTU_LIB_DIR/logging.sh"
fi
source "$JUSTBUNTU_LIB_DIR/reporting.sh"
source "$JUSTBUNTU_LIB_DIR/interactive.sh"
source "$JUSTBUNTU_LIB_DIR/errors/context.sh"
source "$JUSTBUNTU_LIB_DIR/errors/ui.sh"
source "$JUSTBUNTU_LIB_DIR/errors/traps.sh"
install_error_traps
