#!/bin/bash
# Error state and call-path context.

if [[ "${JUSTBUNTU_ERROR_CONTEXT_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_ERROR_CONTEXT_LOADED=true

ERROR_HANDLING=false
JUSTBUNTU_ERROR_CODE=1
JUSTBUNTU_ERROR_COMMAND="unknown"
JUSTBUNTU_ERROR_SOURCE="unknown"
JUSTBUNTU_ERROR_LINE="unknown"
JUSTBUNTU_ERROR_FUNCTION="unknown"
JUSTBUNTU_ERROR_STACK=""
JUSTBUNTU_ERROR_ID=""

record_error_context() {
  JUSTBUNTU_ERROR_CODE="${1:-1}"
  JUSTBUNTU_ERROR_COMMAND="${2:-unknown}"
  JUSTBUNTU_ERROR_SOURCE="${3:-unknown}"
  JUSTBUNTU_ERROR_LINE="${4:-unknown}"
  JUSTBUNTU_ERROR_FUNCTION="${5:-unknown}"
  JUSTBUNTU_ERROR_ID="${JUSTBUNTU_SESSION_ID:-session}-${BASHPID:-$$}-$(date +%s)-${RANDOM:-0}"
}

build_stack_trace() {
  local mode="${1:-print}"
  local frame=0 caller_output line function_name file output=""

  while caller_output=$(caller "$frame" 2>/dev/null); do
    read -r line function_name file <<<"$caller_output"
    output+="  in ${function_name:-main}() at ${file:-unknown}:${line:-unknown}"$'\n'
    ((frame += 1))
  done

  if [[ "$mode" == "capture" ]]; then
    JUSTBUNTU_ERROR_STACK="$output"
  else
    printf '%s' "$output"
  fi
}

capture_error_stack() {
  build_stack_trace capture
}
