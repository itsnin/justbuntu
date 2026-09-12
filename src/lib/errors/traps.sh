#!/bin/bash
# Trap installation and failure orchestration.

if [[ "${JUSTBUNTU_ERROR_TRAPS_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_ERROR_TRAPS_LOADED=true

handle_failure() {
  local exit_code="$JUSTBUNTU_ERROR_CODE"

  if [[ "$ERROR_HANDLING" == "true" ]]; then
    return 0
  fi
  ERROR_HANDLING=true
  trap - ERR
  set +eE
  drain_terminal
  clear_screen
  log_error "event=installation_failed error_id=${JUSTBUNTU_ERROR_ID:-unknown} phase=${JUSTBUNTU_PHASE:-unknown} exit_code=$exit_code"
  finish_install_log "failed"
  print_failure_summary
  printf 'Stack trace:\n'
  if [[ -n "$JUSTBUNTU_ERROR_STACK" ]]; then
    printf '%s\n' "$JUSTBUNTU_ERROR_STACK"
  else
    build_stack_trace
  fi
  printf '\n'
  if ! create_failure_report; then
    log_warn 'event=failure_report_unavailable'
  fi
  JUSTBUNTU_FAILURE_MENU_ACTIVE=true
  export JUSTBUNTU_FAILURE_MENU_ACTIVE
  failure_menu || true
  exit "$exit_code"
}

error_trap() {
  local exit_code="$1"

  record_error_context "$exit_code" "${2:-unknown}" "${3:-unknown}" \
    "${4:-unknown}" "${5:-unknown}"
  capture_error_stack
  handle_failure
}

signal_trap() {
  record_error_context 130 "installer interrupted by SIG$1" \
    "${CURRENT_SCRIPT_PATH:-install.sh}" "unknown" "signal_handler"
  capture_error_stack
  handle_failure
}

exit_handler() {
  local exit_code=$?

  if ((exit_code != 0)) && [[ "$ERROR_HANDLING" != "true" ]]; then
    record_error_context "$exit_code" "${BASH_COMMAND:-unknown}" \
      "${BASH_SOURCE[0]:-unknown}" "${BASH_LINENO[0]:-unknown}" "exit_handler"
    capture_error_stack
    handle_failure
  fi
}

install_error_traps() {
  if [[ "${JUSTBUNTU_ERROR_TRAPS_INSTALLED:-false}" == "true" ]]; then
    return 0
  fi
  trap 'error_trap "$?" "${BASH_COMMAND:-unknown}" "${CURRENT_SCRIPT_PATH:-${BASH_SOURCE[0]:-unknown}}" "${BASH_LINENO[0]:-unknown}" "${FUNCNAME[0]:-main}"' ERR
  trap 'signal_trap INT' INT
  trap 'signal_trap TERM' TERM
  trap 'exit_handler' EXIT
  JUSTBUNTU_ERROR_TRAPS_INSTALLED=true
}
