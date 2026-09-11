#!/bin/bash
# Shared logging and provisioning-step helpers.

if [[ "${JUSTBUNTU_LOGGING_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_LOGGING_LOADED=true

LOG_LEVEL="${JUSTBUNTU_LOG_LEVEL:-INFO}"
JUSTBUNTU_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/justbuntu"
JUSTBUNTU_INSTALL_LOG_FILE="${JUSTBUNTU_INSTALL_LOG_FILE:-$JUSTBUNTU_STATE_DIR/install.log}"
JUSTBUNTU_LOGGING_DISABLED=false
JUSTBUNTU_LOGGING_ACTIVE=false
JUSTBUNTU_LOG_FINALIZED=false

redact_sensitive_stream() {
  sed -u -E \
    -e 's/(Authorization:[[:space:]]*(Bearer|token)[[:space:]]+)[^[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/(github_pat_|gh[pousr]_|x-access-token:)[A-Za-z0-9_\/-]+/\1[REDACTED]/g' \
    -e 's/((password|passwd|secret|token|api[_-]?key|private[_-]?key)[[:space:]]*[=:][[:space:]]*)[^[:space:]]+/\1[REDACTED]/Ig'
}

redact_sensitive_text() {
  printf '%s' "$*" | redact_sensitive_stream
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
  (( message_index >= current_index )) || return 0
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
  if [[ -L "$JUSTBUNTU_INSTALL_LOG_FILE" ]] || \
     ! mkdir -p -- "$log_dir" || \
     ! chmod 700 -- "$log_dir" || \
     ! touch -- "$JUSTBUNTU_INSTALL_LOG_FILE" || \
     ! chmod 600 -- "$JUSTBUNTU_INSTALL_LOG_FILE"; then
    JUSTBUNTU_LOGGING_DISABLED=true
    printf 'warning: could not create a private install log at %s; continuing without file logging\n' \
      "$JUSTBUNTU_INSTALL_LOG_FILE" >&2
  fi
}

start_install_log() {
  local start_time

  ensure_log_file
  start_time=$(log_timestamp)
  JUSTBUNTU_START_TIME="$start_time"
  JUSTBUNTU_START_EPOCH=$(date +%s)
  export JUSTBUNTU_START_TIME JUSTBUNTU_START_EPOCH

  if [[ "$JUSTBUNTU_LOGGING_DISABLED" == "true" ]]; then
    return 0
  fi

  {
    printf '\n=== JustBuntu installation started: %s ===\n' "$start_time"
    printf 'session_pid=%s phase=%s\n' "$$" "${JUSTBUNTU_PHASE:-startup}"
  } >>"$JUSTBUNTU_INSTALL_LOG_FILE"

  exec 3>&1
  exec 4>&2
  exec > >(tee >(redact_sensitive_stream >>"$JUSTBUNTU_INSTALL_LOG_FILE")) 2>&1
  JUSTBUNTU_LOGGING_ACTIVE=true
}

restore_tty() {
  if [[ "$JUSTBUNTU_LOGGING_ACTIVE" == "true" ]]; then
    exec >&3 2>&4
  fi
}

enable_logging() {
  if [[ "$JUSTBUNTU_LOGGING_ACTIVE" == "true" ]]; then
    exec > >(tee >(redact_sensitive_stream >>"$JUSTBUNTU_INSTALL_LOG_FILE")) 2>&1
  fi
}

finish_install_log() {
  local status="${1:-completed}"
  local end_time end_epoch duration mins secs

  if [[ "$JUSTBUNTU_LOG_FINALIZED" == "true" ]]; then
    return 0
  fi
  JUSTBUNTU_LOG_FINALIZED=true
  if [[ "$JUSTBUNTU_LOGGING_DISABLED" == "true" || \
        -z "${JUSTBUNTU_START_EPOCH:-}" || \
        ! -f "$JUSTBUNTU_INSTALL_LOG_FILE" ]]; then
    return 0
  fi

  end_time=$(log_timestamp)
  end_epoch=$(date +%s)
  duration=$((end_epoch - JUSTBUNTU_START_EPOCH))
  mins=$((duration / 60))
  secs=$((duration % 60))
  {
    printf '=== JustBuntu installation %s: %s ===\n' "$status" "$end_time"
    printf 'duration=%sm%ss\n\n' "$mins" "$secs"
  } >>"$JUSTBUNTU_INSTALL_LOG_FILE"
}

stop_install_log() {
  finish_install_log "completed"
}

run_script() {
  local script="$1"
  local script_name="${script##*/}"
  local exit_code

  if [[ ! -f "$script" ]]; then
    log_error "event=script_missing script=$script"
    return 1
  fi

  CURRENT_SCRIPT="$script_name"
  CURRENT_SCRIPT_PATH="$script"
  export CURRENT_SCRIPT CURRENT_SCRIPT_PATH
  log_info "event=script_start phase=${JUSTBUNTU_PHASE:-unknown} script=$script"
  if source "$script"; then
    log_info "event=script_complete phase=${JUSTBUNTU_PHASE:-unknown} script=$script"
  else
    exit_code=$?
    log_error "event=script_failed phase=${JUSTBUNTU_PHASE:-unknown} script=$script exit_code=$exit_code"
    return "$exit_code"
  fi
}
