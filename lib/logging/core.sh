#!/bin/bash
# Logging primitives, redaction, and the private log destination.

if [[ "${JUSTBUNTU_LOGGING_CORE_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_LOGGING_CORE_LOADED=true

LOG_LEVEL="${JUSTBUNTU_LOG_LEVEL:-INFO}"
JUSTBUNTU_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/justbuntu"
JUSTBUNTU_INSTALL_LOG_FILE="${JUSTBUNTU_INSTALL_LOG_FILE:-$JUSTBUNTU_STATE_DIR/install.log}"
JUSTBUNTU_LOGGING_DISABLED=false

redact_sensitive_stream() {
  sed -u -E \
    -e 's/(Authorization:[[:space:]]*(Bearer|token)[[:space:]]+)[^[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/(github_pat_|gh[pousr]_|x-access-token:)[A-Za-z0-9_\/-]+/\1[REDACTED]/g' \
    -e 's/((password|passwd|secret|token|api[_-]?key|private[_-]?key)[[:space:]]*[=:][[:space:]]*)("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:]]+)/\1[REDACTED]/Ig'
}

redact_sensitive_text() {
  local text="${*:-}"
  local home_dir="${HOME:-}"

  if [[ "$home_dir" == /* && "$home_dir" != "/" ]]; then
    text="${text//"$home_dir"/~}"
  fi
  printf '%s' "$text" | redact_sensitive_stream
}

log_timestamp() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

log_level_index() {
  case "$1" in
    DEBUG) printf '0\n' ;;
    INFO) printf '1\n' ;;
    WARN) printf '2\n' ;;
    ERROR) printf '3\n' ;;
    *) printf '1\n' ;;
  esac
}

log() {
  local level="$1"
  shift
  local current_index message_index message

  current_index=$(log_level_index "$LOG_LEVEL")
  message_index=$(log_level_index "$level")
  ((message_index >= current_index)) || return 0
  message=$(redact_sensitive_text "$*")
  if [[ "$level" == "WARN" || "$level" == "ERROR" ]]; then
    printf '[%s] [%s] %s\n' "$(log_timestamp)" "$level" "$message" >&2
  else
    printf '[%s] [%s] %s\n' "$(log_timestamp)" "$level" "$message"
  fi
}

log_debug() { log DEBUG "$@"; }
log_info() { log INFO "$@"; }
log_warn() { log WARN "$@"; }
log_error() { log ERROR "$@"; }

ensure_log_file() {
  local log_dir

  if [[ "$JUSTBUNTU_LOGGING_DISABLED" == "true" ]]; then
    return 0
  fi
  log_dir=$(dirname -- "$JUSTBUNTU_INSTALL_LOG_FILE")
  if [[ -L "$log_dir" || -L "$JUSTBUNTU_INSTALL_LOG_FILE" ]] || \
     ! mkdir -p -- "$log_dir" || \
     ! chmod 700 -- "$log_dir" || \
     ! touch -- "$JUSTBUNTU_INSTALL_LOG_FILE" || \
     ! chmod 600 -- "$JUSTBUNTU_INSTALL_LOG_FILE"; then
    JUSTBUNTU_LOGGING_DISABLED=true
    printf 'warning: could not create a private install log at %s; continuing without file logging\n' \
      "$(redact_sensitive_text "$JUSTBUNTU_INSTALL_LOG_FILE")" >&2
  fi
}
