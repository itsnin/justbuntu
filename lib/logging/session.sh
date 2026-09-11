#!/bin/bash
# Installation log stream lifecycle and session metadata.

if [[ "${JUSTBUNTU_LOGGING_SESSION_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_LOGGING_SESSION_LOADED=true

JUSTBUNTU_LOGGING_ACTIVE=false
JUSTBUNTU_LOGGING_REDIRECTED=false
JUSTBUNTU_LOG_FINALIZED=false
JUSTBUNTU_LOG_SINK_DIR=""
JUSTBUNTU_LOGGER_PID=""

start_log_sink() {
  local sink_dir sink_fifo logger_pid

  if ! sink_dir=$(mktemp -d "${TMPDIR:-/tmp}/justbuntu-log.XXXXXX") || \
     ! chmod 700 -- "$sink_dir"; then
    return 1
  fi
  sink_fifo="$sink_dir/stream"
  if ! mkfifo -- "$sink_fifo" || ! chmod 600 -- "$sink_fifo"; then
    rm -rf -- "$sink_dir"
    return 1
  fi

  # Keep fd 5 open across TTY restoration so the reader is not closed between
  # interactive prompts and normal logged output.
  (redact_sensitive_stream <"$sink_fifo" | \
    tee --append -- "$JUSTBUNTU_INSTALL_LOG_FILE" >&3) &
  logger_pid=$!
  if ! exec 5>"$sink_fifo"; then
    kill "$logger_pid" 2>/dev/null || true
    wait "$logger_pid" 2>/dev/null || true
    rm -rf -- "$sink_dir"
    return 1
  fi
  rm -f -- "$sink_fifo"
  JUSTBUNTU_LOG_SINK_DIR="$sink_dir"
  JUSTBUNTU_LOGGER_PID="$logger_pid"
}

stop_log_sink() {
  local sink_status=0

  exec 5>&- || true
  if [[ -n "$JUSTBUNTU_LOGGER_PID" ]]; then
    if wait "$JUSTBUNTU_LOGGER_PID"; then
      sink_status=0
    else
      sink_status=$?
    fi
  fi
  if [[ -n "$JUSTBUNTU_LOG_SINK_DIR" ]]; then
    rm -rf -- "$JUSTBUNTU_LOG_SINK_DIR"
  fi
  JUSTBUNTU_LOGGING_ACTIVE=false
  JUSTBUNTU_LOGGING_REDIRECTED=false
  JUSTBUNTU_LOG_SINK_DIR=""
  JUSTBUNTU_LOGGER_PID=""
  return "$sink_status"
}

start_install_log() {
  local start_time

  if [[ "$JUSTBUNTU_LOGGING_ACTIVE" == "true" ]]; then
    return 0
  fi
  ensure_log_file
  start_time=$(log_timestamp)
  JUSTBUNTU_START_TIME="$start_time"
  JUSTBUNTU_START_EPOCH=$(date +%s)
  JUSTBUNTU_SESSION_ID="${JUSTBUNTU_SESSION_ID:-${JUSTBUNTU_START_EPOCH}-$$}"
  export JUSTBUNTU_START_TIME JUSTBUNTU_START_EPOCH JUSTBUNTU_SESSION_ID

  if [[ "$JUSTBUNTU_LOGGING_DISABLED" == "true" ]]; then
    return 0
  fi

  {
    printf '\n=== JustBuntu installation started: %s ===\n' "$start_time"
    printf 'session_id=%s session_pid=%s phase=%s\n' \
      "$JUSTBUNTU_SESSION_ID" "$$" "${JUSTBUNTU_PHASE:-startup}"
  } >>"$JUSTBUNTU_INSTALL_LOG_FILE"

  exec 3>&1
  exec 4>&2
  if ! start_log_sink; then
    JUSTBUNTU_LOGGING_DISABLED=true
    printf 'warning: could not start the private log sink; continuing without file logging\n' >&2
    return 0
  fi
  exec 1>&5 2>&5
  JUSTBUNTU_LOGGING_ACTIVE=true
  JUSTBUNTU_LOGGING_REDIRECTED=true
}

restore_tty() {
  if [[ "$JUSTBUNTU_LOGGING_REDIRECTED" == "true" ]]; then
    exec >&3 2>&4
    JUSTBUNTU_LOGGING_REDIRECTED=false
  fi
}

enable_logging() {
  if [[ "$JUSTBUNTU_LOGGING_ACTIVE" == "true" && \
        "$JUSTBUNTU_LOGGING_REDIRECTED" == "false" ]]; then
    exec 1>&5 2>&5
    JUSTBUNTU_LOGGING_REDIRECTED=true
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

  if [[ -n "$JUSTBUNTU_LOGGER_PID" ]]; then
    restore_tty
    if ! stop_log_sink; then
      printf 'warning: the private log sink did not close cleanly\n' >&2
    fi
  fi

  end_time=$(log_timestamp)
  end_epoch=$(date +%s)
  duration=$((end_epoch - JUSTBUNTU_START_EPOCH))
  mins=$((duration / 60))
  secs=$((duration % 60))
  {
    printf '=== JustBuntu installation %s: %s ===\n' "$status" "$end_time"
    printf 'session_id=%s duration=%sm%ss\n\n' \
      "${JUSTBUNTU_SESSION_ID:-unknown}" "$mins" "$secs"
  } >>"$JUSTBUNTU_INSTALL_LOG_FILE"
}

stop_install_log() {
  finish_install_log "completed"
}
