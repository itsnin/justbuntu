#!/bin/bash
# Local redacted failure-report generation.

if [[ "${JUSTBUNTU_REPORT_BUILDER_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_REPORT_BUILDER_LOADED=true

JUSTBUNTU_LAST_REPORT_FILE=""

report_value() {
  redact_sensitive_text "${1:-unknown}" | tr '\n' ' '
}

create_failure_report() {
  local report_dir report_file os_name kernel desktop project_version

  report_dir="${XDG_STATE_HOME:-$HOME/.local/state}/justbuntu/reports"
  if [[ -L "$report_dir" ]] || ! mkdir -p -- "$report_dir" || \
     ! chmod 700 -- "$report_dir"; then
    printf 'warning: could not create private report directory: %s\n' \
      "$(redact_sensitive_text "$report_dir")" >&2
    return 1
  fi
  if ! report_file=$(mktemp -- "$report_dir/failure.XXXXXX.txt") || \
     ! chmod 600 -- "$report_file"; then
    printf 'warning: could not create a private failure report\n' >&2
    [[ -n "$report_file" ]] && rm -f -- "$report_file"
    return 1
  fi

  os_name=$(sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | head -n 1 | tr -d '"')
  kernel=$(uname -srmo 2>/dev/null || printf 'unknown')
  desktop="${XDG_CURRENT_DESKTOP:-unknown}"
  project_version=$(cat "${JUSTBUNTU_ROOT:-$HOME/.local/share/justbuntu}/version" 2>/dev/null || printf 'unknown')
  if ! {
    printf '## JustBuntu installation failure\n\n'
    printf 'This report was generated locally and redacted before any optional submission.\n\n'
    printf '### Report context\n\n'
    printf -- '- Error ID: %s\n' "$(report_value "${JUSTBUNTU_ERROR_ID:-unknown}")"
    printf -- '- Session ID: %s\n' "$(report_value "${JUSTBUNTU_SESSION_ID:-unknown}")"
    printf -- '- Log file: %s\n' "$(report_value "${JUSTBUNTU_INSTALL_LOG_FILE:-unknown}")"
    printf '\n### System\n\n'
    printf -- '- Ubuntu: %s\n' "$(report_value "$os_name")"
    printf -- '- Kernel: %s\n' "$(report_value "$kernel")"
    printf -- '- Architecture: %s\n' "$(report_value "$(uname -m 2>/dev/null || printf 'unknown')")"
    printf -- '- Desktop: %s\n' "$(report_value "$desktop")"
    printf -- '- Project version: %s\n' "$(report_value "$project_version")"
    printf '\n### Failure context\n\n'
    printf -- '- Phase: %s\n' "$(report_value "${JUSTBUNTU_PHASE:-unknown}")"
    printf -- '- Script: %s\n' "$(report_value "${CURRENT_SCRIPT_PATH:-${CURRENT_SCRIPT:-unknown}}")"
    printf -- '- Function: %s\n' "$(report_value "${JUSTBUNTU_ERROR_FUNCTION:-unknown}")"
    printf -- '- Source line: %s\n' "$(report_value "${JUSTBUNTU_ERROR_LINE:-unknown}")"
    printf -- '- Exit code: %s\n' "$(report_value "${JUSTBUNTU_ERROR_CODE:-unknown}")"
    printf -- '- Failed command: `%s`\n' "$(report_value "${JUSTBUNTU_ERROR_COMMAND:-unknown}")"
    printf '\n### Call path\n\n```text\n'
    if [[ -n "${JUSTBUNTU_ERROR_STACK:-}" ]]; then
      redact_sensitive_text "$JUSTBUNTU_ERROR_STACK"
    else
      printf 'The call path was unavailable.\n'
    fi
    printf '```\n\n### Recent redacted log output\n\n```text\n'
    if [[ -f "${JUSTBUNTU_INSTALL_LOG_FILE:-}" ]]; then
      tail -n 120 -- "$JUSTBUNTU_INSTALL_LOG_FILE" | redact_sensitive_stream
    else
      printf 'The session log was unavailable.\n'
    fi
    printf '```\n'
  } >"$report_file"; then
    printf 'warning: could not write the private failure report\n' >&2
    rm -f -- "$report_file"
    return 1
  fi

  JUSTBUNTU_LAST_REPORT_FILE="$report_file"
  export JUSTBUNTU_LAST_REPORT_FILE
  printf 'Redacted failure report saved to: %s\n' \
    "$(redact_sensitive_text "$report_file")"
}
