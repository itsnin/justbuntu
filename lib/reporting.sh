#!/bin/bash
# Redacted failure reports and optional GitHub issue submission.

if [[ "${JUSTBUNTU_REPORTING_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_REPORTING_LOADED=true

JUSTBUNTU_REPORT_REPOSITORY="itsnin/justbuntu"
JUSTBUNTU_LAST_REPORT_FILE=""

report_value() {
  printf '%s' "${1:-unknown}" | redact_sensitive_stream | tr '\n' ' '
}

create_failure_report() {
  local report_dir report_file os_name kernel desktop

  report_dir="${XDG_STATE_HOME:-$HOME/.local/state}/justbuntu/reports"
  if ! mkdir -p -- "$report_dir" || ! chmod 700 -- "$report_dir"; then
    printf 'warning: could not create private report directory: %s\n' "$report_dir" >&2
    return 1
  fi
  if ! report_file=$(mktemp "$report_dir/failure.XXXXXX.txt"); then
    printf 'warning: could not create a private failure report\n' >&2
    return 1
  fi
  chmod 600 -- "$report_file"

  os_name=$(sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | head -n 1 | tr -d '"')
  kernel=$(uname -srmo 2>/dev/null || printf 'unknown')
  desktop="${XDG_CURRENT_DESKTOP:-unknown}"
  {
    printf '## JustBuntu installation failure\n\n'
    printf 'This report was generated locally and redacted before any optional submission.\n\n'
    printf '### System\n\n'
    printf -- '- Ubuntu: %s\n' "$(report_value "$os_name")"
    printf -- '- Kernel: %s\n' "$(report_value "$kernel")"
    printf -- '- Architecture: %s\n' "$(report_value "$(uname -m 2>/dev/null || printf 'unknown')")"
    printf -- '- Desktop: %s\n' "$(report_value "$desktop")"
    printf -- "- Project version: %s\n" "$(report_value "$(cat "${JUSTBUNTU_PATH:-$HOME/.local/share/justbuntu}/version" 2>/dev/null || printf 'unknown')")"
    printf '\n### Failure context\n\n'
    printf -- '- Phase: %s\n' "$(report_value "${JUSTBUNTU_PHASE:-unknown}")"
    printf -- '- Script: %s\n' "$(report_value "${CURRENT_SCRIPT_PATH:-${CURRENT_SCRIPT:-unknown}}")"
    printf -- '- Function: %s\n' "$(report_value "${JUSTBUNTU_ERROR_FUNCTION:-unknown}")"
    printf -- '- Source line: %s\n' "$(report_value "${JUSTBUNTU_ERROR_LINE:-unknown}")"
    printf -- '- Exit code: %s\n' "$(report_value "${JUSTBUNTU_ERROR_CODE:-unknown}")"
    printf -- '- Failed command: `%s`\n' "$(report_value "${JUSTBUNTU_ERROR_COMMAND:-unknown}")"
    printf '\n### Recent redacted log output\n\n```text\n'
    if [[ -f "${JUSTBUNTU_INSTALL_LOG_FILE:-}" ]]; then
      tail -n 120 -- "$JUSTBUNTU_INSTALL_LOG_FILE" | redact_sensitive_stream
    else
      printf 'The session log was unavailable.\n'
    fi
    printf '```\n'
  } >"$report_file"

  JUSTBUNTU_LAST_REPORT_FILE="$report_file"
  export JUSTBUNTU_LAST_REPORT_FILE
  printf 'Redacted failure report saved to: %s\n' "$report_file"
}

send_failure_report() {
  local report_file="$1"
  local github_token="${2:-}"
  local submission_dir payload_file curl_config response_file
  local issue_url http_code curl_status

  if [[ ! -s "$report_file" ]]; then
    printf 'warning: failure report is missing or empty\n' >&2
    return 1
  fi
  if ! command -v curl >/dev/null 2>&1; then
    return 2
  fi
  if [[ -z "$github_token" ]]; then
    return 3
  fi

  if ! submission_dir=$(mktemp -d "${TMPDIR:-/tmp}/justbuntu-submit.XXXXXX") ||
     ! chmod 700 -- "$submission_dir"; then
    return 3
  fi
  payload_file="$submission_dir/payload.json"
  curl_config="$submission_dir/curl.conf"
  response_file="$submission_dir/response.json"

  # Build JSON without placing the credential in the report or shell output.
  # Escaping also protects the API request if diagnostics contain quotes,
  # backslashes, or control bytes.
  {
    printf '{"title":"JustBuntu installation failure","body":"'
    tr -d '\000-\010\013\014\015\016-\037' <"$report_file" |
      sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' |
      awk '{printf "%s\\n", $0}'
    printf '"}\n'
  } >"$payload_file"

  {
    printf 'url = "https://api.github.com/repos/%s/issues"\n' "$JUSTBUNTU_REPORT_REPOSITORY"
    printf 'request = "POST"\n'
    printf 'header = "Accept: application/vnd.github+json"\n'
    printf 'header = "X-GitHub-Api-Version: 2022-11-28"\n'
    printf 'header = "Content-Type: application/json"\n'
    printf 'header = "Authorization: Bearer %s"\n' "$github_token"
    printf 'data-binary = "@%s"\n' "$payload_file"
  } >"$curl_config"
  chmod 600 -- "$payload_file" "$curl_config"

  if http_code=$(curl --silent --show-error --fail-with-body \
      --config "$curl_config" --output "$response_file" --write-out '%{http_code}'); then
    curl_status=0
  else
    curl_status=$?
  fi
  if ((curl_status != 0)); then
    rm -rf -- "$submission_dir"
    printf 'warning: GitHub issue submission failed; the report remains at %s\n' \
      "$report_file" >&2
    case "$http_code" in
      401|403|404) return 4 ;;
      *) return 5 ;;
    esac
  fi
  issue_url=$(sed -n 's/.*"html_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    "$response_file" | head -n 1)
  if [[ "$http_code" != 2* || -z "$issue_url" ]]; then
    rm -rf -- "$submission_dir"
    printf 'warning: GitHub issue submission returned an unexpected response; the report remains at %s\n' \
      "$report_file" >&2
    return 1
  fi

  rm -rf -- "$submission_dir"
  printf 'GitHub issue created: %s\n' "$issue_url"
}
