#!/bin/bash
# Shell-facing protocol for the JustBuntu terminal application.

if [[ "${JUSTBUNTU_INTERACTIVE_LOADED:-false}" == "true" ]]; then
  return 0
fi
JUSTBUNTU_INTERACTIVE_LOADED=true

JUSTBUNTU_ROOT="${JUSTBUNTU_ROOT:-${HOME}/.local/share/justbuntu}"
JUSTBUNTU_APP_BIN="${JUSTBUNTU_APP_BIN:-$JUSTBUNTU_ROOT/libexec/justbuntu}"
export JUSTBUNTU_ROOT JUSTBUNTU_APP_BIN

justbuntu_app() {
  if [[ ! -x "$JUSTBUNTU_APP_BIN" ]]; then
    printf 'error: JustBuntu terminal application is unavailable at %s\n' \
      "$JUSTBUNTU_APP_BIN" >&2
    return 1
  fi
  "$JUSTBUNTU_APP_BIN" "$@"
}

justbuntu_select() {
  local title="$1"
  local selected="$2"
  local mode="$3"
  shift 3

  local -a options=(select --title "$title")
  [[ -n "$selected" ]] && options+=(--selected "$selected")
  [[ "$mode" == "single" ]] && options+=(--single)
  options+=("$@")
  justbuntu_app "${options[@]}"
}

justbuntu_confirm() {
  local title="$1"
  local default_answer="${2:-yes}"
  justbuntu_app confirm --title "$title" --default "$default_answer"
}

justbuntu_input() {
  local title="$1"
  local default_value="${2:-}"
  local password="${3:-false}"
  local -a options=(input --title "$title" --default "$default_value")
  [[ "$password" == "true" ]] && options+=(--password)
  justbuntu_app "${options[@]}"
}
