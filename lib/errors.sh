#!/bin/bash
# Central failure handling for the installer.

if [[ "${JUSTBUNTU_ERRORS_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_ERRORS_LOADED=true

JUSTBUNTU_LIB_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if ! declare -F log_error >/dev/null 2>&1; then
  source "$JUSTBUNTU_LIB_DIR/logging.sh"
fi
source "$JUSTBUNTU_LIB_DIR/reporting.sh"

ERROR_HANDLING=false
JUSTBUNTU_ERROR_CODE=1
JUSTBUNTU_ERROR_COMMAND="unknown"
JUSTBUNTU_ERROR_SOURCE="unknown"
JUSTBUNTU_ERROR_LINE="unknown"
JUSTBUNTU_ERROR_FUNCTION="unknown"

drain_terminal() {
  if [[ -t 0 ]]; then
    stty -echo 2>/dev/null || true
    while read -r -t 0.3 -n 1024 2>/dev/null; do :; done
    stty echo 2>/dev/null || true
  fi
  stty sane 2>/dev/null || true
}

clear_screen() {
  printf '\033[H\033[2J'
}

build_stack_trace() {
  local frame=0 caller_output line function_name file
  while caller_output=$(caller "$frame" 2>/dev/null); do
    read -r line function_name file <<<"$caller_output"
    printf '  in %s() at %s:%s\n' \
      "${function_name:-main}" "${file:-unknown}" "${line:-unknown}"
    ((frame += 1))
  done
}

record_error_context() {
  JUSTBUNTU_ERROR_CODE="${1:-1}"
  JUSTBUNTU_ERROR_COMMAND="${2:-unknown}"
  JUSTBUNTU_ERROR_SOURCE="${3:-unknown}"
  JUSTBUNTU_ERROR_LINE="${4:-unknown}"
  JUSTBUNTU_ERROR_FUNCTION="${5:-unknown}"
  export JUSTBUNTU_ERROR_CODE JUSTBUNTU_ERROR_COMMAND JUSTBUNTU_ERROR_SOURCE \
    JUSTBUNTU_ERROR_LINE JUSTBUNTU_ERROR_FUNCTION
}

print_failure_summary() {
  local summary="JustBuntu installation stopped"
  if command -v gum >/dev/null 2>&1; then
    gum style --foreground 1 "$summary"
  else
    printf '\n%s\n' "$summary" >&2
  fi
  printf 'Phase: %s | Script: %s | Line: %s | Exit code: %s\n' \
    "$(redact_sensitive_text "${JUSTBUNTU_PHASE:-unknown}")" \
    "$(redact_sensitive_text "${CURRENT_SCRIPT:-unknown}")" \
    "$(redact_sensitive_text "$JUSTBUNTU_ERROR_LINE")" \
    "$(redact_sensitive_text "$JUSTBUNTU_ERROR_CODE")" >&2
  printf 'Command: %s\n' "$(redact_sensitive_text "$JUSTBUNTU_ERROR_COMMAND")" >&2
  printf 'Source: %s\n\n' "$(redact_sensitive_text "$JUSTBUNTU_ERROR_SOURCE")" >&2
}

show_recent_log() {
  if [[ -f "${JUSTBUNTU_INSTALL_LOG_FILE:-}" ]]; then
    if command -v less >/dev/null 2>&1; then
      less -- "$JUSTBUNTU_INSTALL_LOG_FILE"
    else
      tail -n 120 -- "$JUSTBUNTU_INSTALL_LOG_FILE"
    fi
  else
    printf 'The session log is unavailable.\n' >&2
  fi
}

retry_installation() {
  local install_path="${JUSTBUNTU_PATH:-$HOME/.local/share/justbuntu}/install.sh"
  if declare -F stop_sudo_keepalive >/dev/null 2>&1; then
    stop_sudo_keepalive
  fi
  if [[ ! -f "$install_path" ]]; then
    printf 'error: cannot retry; installer was not found at %s\n' "$install_path" >&2
    return 1
  fi
  exec bash -- "$install_path"
}

prompt_submission_token() {
  local github_token="" status

  if ! command -v gum >/dev/null 2>&1; then
    printf 'gum is not installed. The redacted report remains at: %s\n' \
      "$JUSTBUNTU_LAST_REPORT_FILE" >&2
    return 0
  fi

  if ! github_token=$(gum input --password \
    --prompt 'GitHub token> ' \
    --header 'Personal access token with Issues: write; leave empty to cancel'); then
    printf 'Submission cancelled. The redacted report remains at: %s\n' \
      "$JUSTBUNTU_LAST_REPORT_FILE"
    return 0
  fi
  if [[ -z "$github_token" ]]; then
    printf 'No GitHub token was provided. The redacted report remains at: %s\n' \
      "$JUSTBUNTU_LAST_REPORT_FILE"
    return 0
  fi

  send_failure_report "$JUSTBUNTU_LAST_REPORT_FILE" "$github_token"
  status=$?
  unset github_token

  case "$status" in
    0)
      return 0
      ;;
    2)
      printf 'curl is not installed. The redacted report remains at: %s\n' \
        "$JUSTBUNTU_LAST_REPORT_FILE"
      ;;
    3)
      printf 'No GitHub token was available. The redacted report remains at: %s\n' \
        "$JUSTBUNTU_LAST_REPORT_FILE"
      ;;
    4)
      printf 'GitHub rejected the token or it lacks permission to create issues. The redacted report remains at: %s\n' \
        "$JUSTBUNTU_LAST_REPORT_FILE" >&2
      ;;
    5)
      printf 'GitHub could not be reached or returned an unexpected response. The redacted report remains at: %s\n' \
        "$JUSTBUNTU_LAST_REPORT_FILE" >&2
      ;;
    *)
      printf 'The report was not submitted; it remains at: %s\n' \
        "$JUSTBUNTU_LAST_REPORT_FILE" >&2
      ;;
  esac
  return 0
}

send_or_explain_report() {
  prompt_submission_token
}

failure_menu() {
  local choice

  if ! command -v gum >/dev/null 2>&1 || [[ ! -t 0 && ! -t 3 ]]; then
    printf 'Run the installer again after reviewing the report if needed.\n' >&2
    return 1
  fi

  while true; do
    choice=$(gum choose \
      'Retry installation' \
      'View recent log' \
      'Submit redacted report to GitHub' \
      'Exit' \
      --header 'Choose what to do next' --height 8) || choice='Exit'
    case "$choice" in
      'Retry installation')
        clear_screen
        retry_installation
        ;;
      'View recent log')
        show_recent_log
        ;;
      'Submit redacted report to GitHub')
        send_or_explain_report
        ;;
      *)
        return 1
        ;;
    esac
  done
}

handle_failure() {
  local exit_code="$JUSTBUNTU_ERROR_CODE"

  if [[ "$ERROR_HANDLING" == "true" ]]; then
    return
  fi
  ERROR_HANDLING=true
  trap - ERR
  set +eE
  drain_terminal
  clear_screen
  finish_install_log "failed"
  print_failure_summary
  printf 'Stack trace:\n'
  build_stack_trace
  printf '\n'
  create_failure_report || true
  failure_menu || true
  exit "$exit_code"
}

error_trap() {
  local exit_code="$1"
  record_error_context "$exit_code" "${2:-unknown}" "${3:-unknown}" \
    "${4:-unknown}" "${5:-unknown}"
  handle_failure
}

signal_trap() {
  record_error_context 130 "installer interrupted by SIG$1" \
    "${CURRENT_SCRIPT_PATH:-install.sh}" "unknown" "signal_handler"
  handle_failure
}

exit_handler() {
  local exit_code=$?
  if ((exit_code != 0)) && [[ "$ERROR_HANDLING" != "true" ]]; then
    record_error_context "$exit_code" "${BASH_COMMAND:-unknown}" \
      "${BASH_SOURCE[0]:-unknown}" "${BASH_LINENO[0]:-unknown}" "exit_handler"
    handle_failure
  fi
}

trap 'error_trap "$?" "${BASH_COMMAND:-unknown}" "${CURRENT_SCRIPT_PATH:-${BASH_SOURCE[0]:-unknown}}" "${BASH_LINENO[0]:-unknown}" "${FUNCNAME[0]:-main}"' ERR
trap 'signal_trap INT' INT
trap 'signal_trap TERM' TERM
trap exit_handler EXIT
