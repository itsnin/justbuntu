#!/bin/bash
# Shared sourced-script execution boundary.

if [[ "${JUSTBUNTU_LOGGING_EXECUTION_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_LOGGING_EXECUTION_LOADED=true

run_script() {
  local script="$1"
  local script_name="${script##*/}"
  local exit_code
  local previous_script="${CURRENT_SCRIPT:-}"
  local previous_script_path="${CURRENT_SCRIPT_PATH:-}"
  local had_previous_script=false
  local had_previous_script_path=false

  [[ -v CURRENT_SCRIPT ]] && had_previous_script=true
  [[ -v CURRENT_SCRIPT_PATH ]] && had_previous_script_path=true

  if [[ ! -f "$script" ]]; then
    log_error "event=script_missing phase=${JUSTBUNTU_PHASE:-unknown} script=$script_name"
    return 1
  fi

  CURRENT_SCRIPT="$script_name"
  CURRENT_SCRIPT_PATH="$script"
  log_info "event=script_start phase=${JUSTBUNTU_PHASE:-unknown} script=$script_name"
  # Putting source in an if-condition suppresses ERR inside the sourced file.
  # Capture the status outside a conditional so the trap can retain context.
  set +e
  source "$script"
  exit_code=$?
  set -e
  if ((exit_code == 0)); then
    log_info "event=script_complete phase=${JUSTBUNTU_PHASE:-unknown} script=$script_name"
    if [[ "$had_previous_script" == "true" ]]; then
      CURRENT_SCRIPT="$previous_script"
    else
      unset CURRENT_SCRIPT
    fi
    if [[ "$had_previous_script_path" == "true" ]]; then
      CURRENT_SCRIPT_PATH="$previous_script_path"
    else
      unset CURRENT_SCRIPT_PATH
    fi
  else
    log_error "event=script_failed phase=${JUSTBUNTU_PHASE:-unknown} script=$script_name exit_code=$exit_code"
    return "$exit_code"
  fi
}
