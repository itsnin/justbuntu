#!/bin/bash
# Optional direct GitHub issue transport for an existing local report.

if [[ "${JUSTBUNTU_GITHUB_TRANSPORT_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_GITHUB_TRANSPORT_LOADED=true

JUSTBUNTU_REPORT_REPOSITORY="itsnin/justbuntu"

send_failure_report() {
  local report_file="${1:-}"
  local github_token="${2:-}"
  local submission_dir payload_file curl_config response_file
  local issue_url http_code curl_status escaped_token

  if [[ ! -f "$report_file" || -L "$report_file" || ! -s "$report_file" ]]; then
    printf 'warning: failure report is missing, empty, or not a regular file\n' >&2
    return 1
  fi
  if ! command -v curl >/dev/null 2>&1; then
    return 2
  fi
  if [[ -z "$github_token" ]]; then
    return 3
  fi
  if [[ "$github_token" == *$'\n'* || "$github_token" == *$'\r'* ]]; then
    printf 'warning: the GitHub credential contains an invalid line break\n' >&2
    return 4
  fi

  if ! submission_dir=$(mktemp -d "${TMPDIR:-/tmp}/justbuntu-submit.XXXXXX"); then
    return 3
  fi
  if ! chmod 700 -- "$submission_dir"; then
    rm -rf -- "$submission_dir"
    return 3
  fi
  payload_file="$submission_dir/payload.json"
  curl_config="$submission_dir/curl.conf"
  response_file="$submission_dir/response.json"

  # Build JSON without placing the credential in the report or shell output.
  # Escaping also protects the API request if diagnostics contain quotes,
  # backslashes, or control bytes.
  if ! {
    printf '{"title":"JustBuntu installation failure","body":"'
    tr -d '\000-\010\013\014\015\016-\037' <"$report_file" |
      sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' |
      awk '{printf "%s\\n", $0}'
    printf '"}\n'
  } >"$payload_file"; then
    rm -rf -- "$submission_dir"
    return 1
  fi

  escaped_token="${github_token//\\/\\\\}"
  escaped_token="${escaped_token//\"/\\\"}"
  if ! {
    printf 'url = "https://api.github.com/repos/%s/issues"\n' "$JUSTBUNTU_REPORT_REPOSITORY"
    printf 'request = "POST"\n'
    printf 'connect-timeout = 15\n'
    printf 'max-time = 60\n'
    printf 'retry = 2\n'
    printf 'retry-delay = 1\n'
    printf 'header = "Accept: application/vnd.github+json"\n'
    printf 'header = "X-GitHub-Api-Version: 2022-11-28"\n'
    printf 'header = "Content-Type: application/json"\n'
    printf 'header = "Authorization: Bearer %s"\n' "$escaped_token"
    printf 'data-binary = "@%s"\n' "$payload_file"
  } >"$curl_config"; then
    rm -rf -- "$submission_dir"
    return 1
  fi
  if ! chmod 600 -- "$payload_file" "$curl_config"; then
    rm -rf -- "$submission_dir"
    return 1
  fi

  if http_code=$(curl --silent --show-error --fail-with-body \
      --config "$curl_config" --output "$response_file" --write-out '%{http_code}'); then
    curl_status=0
  else
    curl_status=$?
  fi
  if ((curl_status != 0)); then
    rm -rf -- "$submission_dir"
    printf 'warning: GitHub issue submission failed; the report remains at %s\n' \
      "$(redact_sensitive_text "$report_file")" >&2
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
      "$(redact_sensitive_text "$report_file")" >&2
    return 1
  fi

  rm -rf -- "$submission_dir"
  printf 'GitHub issue created: %s\n' "$issue_url"
}
