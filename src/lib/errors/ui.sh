#!/bin/bash
# Failure presentation and user recovery actions.

if [[ "${JUSTBUNTU_ERROR_UI_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_ERROR_UI_LOADED=true

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

print_failure_summary() {
  local summary="JustBuntu installation stopped"

  printf '\n\033[1;31m%s\033[0m\n' "$summary" >&2
  printf 'Error ID: %s\n' \
    "$(redact_sensitive_text "${JUSTBUNTU_ERROR_ID:-unknown}")" >&2
  printf 'Phase: %s | Script: %s | Line: %s | Exit code: %s\n' \
    "$(redact_sensitive_text "${JUSTBUNTU_PHASE:-unknown}")" \
    "$(redact_sensitive_text "${CURRENT_SCRIPT:-unknown}")" \
    "$(redact_sensitive_text "$JUSTBUNTU_ERROR_LINE")" \
    "$(redact_sensitive_text "$JUSTBUNTU_ERROR_CODE")" >&2
  printf 'Command: %s\n' "$(redact_sensitive_text "$JUSTBUNTU_ERROR_COMMAND")" >&2
  printf 'Source: %s\n' "$(redact_sensitive_text "$JUSTBUNTU_ERROR_SOURCE")" >&2
  printf 'Log: %s\n\n' \
    "$(redact_sensitive_text "${JUSTBUNTU_INSTALL_LOG_FILE:-unavailable}")" >&2
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
  local install_path="${JUSTBUNTU_ROOT:-$HOME/.local/share/justbuntu}/install.sh"

  if declare -F stop_sudo_keepalive >/dev/null 2>&1; then
    stop_sudo_keepalive
  fi
  if [[ ! -f "$install_path" ]]; then
    printf 'error: cannot retry; installer was not found at %s\n' \
      "$(redact_sensitive_text "$install_path")" >&2
    return 1
  fi
  exec bash -- "$install_path"
}

prompt_submission_token() {
  local github_token="" status

  if [[ "${JUSTBUNTU_FAILURE_MENU_ACTIVE:-false}" != "true" ]]; then
    printf 'Issue submission is available only after an installation failure.\n' >&2
    return 1
  fi
  if [[ ! -s "${JUSTBUNTU_LAST_REPORT_FILE:-}" ]]; then
    printf 'No redacted failure report is available for submission.\n' >&2
    return 1
  fi

  if [[ ! -x "${JUSTBUNTU_APP_BIN:-}" ]]; then
    printf 'The terminal application is unavailable. The redacted report remains at: %s\n' \
      "$JUSTBUNTU_LAST_REPORT_FILE" >&2
    return 0
  fi

  if ! github_token=$(justbuntu_input \
    'Failure-only issue submission credential (leave empty to cancel)' '' true); then
    printf 'Submission cancelled. The redacted report remains at: %s\n' \
      "$JUSTBUNTU_LAST_REPORT_FILE"
    return 0
  fi
  if [[ -z "$github_token" ]]; then
    printf 'No GitHub credential was provided. The redacted report remains at: %s\n' \
      "$JUSTBUNTU_LAST_REPORT_FILE"
    return 0
  fi

  if send_failure_report "$JUSTBUNTU_LAST_REPORT_FILE" "$github_token"; then
    status=0
  else
    status=$?
  fi
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
      printf 'No GitHub credential was available. The redacted report remains at: %s\n' \
        "$JUSTBUNTU_LAST_REPORT_FILE"
      ;;
    4)
      printf 'GitHub rejected the credential or it lacks permission to create issues. The redacted report remains at: %s\n' \
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

  if [[ ! -x "${JUSTBUNTU_APP_BIN:-}" ]] || [[ ! -t 0 && ! -t 3 ]]; then
    printf 'Run the installer again after reviewing the report if needed.\n' >&2
    return 1
  fi

  while true; do
    choice=$(justbuntu_select \
      'Choose what to do next' '' single \
      'Retry installation' \
      'View recent log' \
      'Submit redacted report to GitHub' \
      'Exit') || choice='Exit'
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
