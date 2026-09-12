#!/bin/bash
# Public reporting facade. Implementation is split between creation and transport.

if [[ "${JUSTBUNTU_REPORTING_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_REPORTING_LOADED=true

JUSTBUNTU_REPORTING_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/reporting" && pwd)
source "$JUSTBUNTU_REPORTING_DIR/report-builder.sh"
source "$JUSTBUNTU_REPORTING_DIR/github-transport.sh"
