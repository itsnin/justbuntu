#!/bin/bash
# error handling — graceful recovery with retry menu and log inspection.
# requires set -eE for the ERR trap to propagate into functions.
ERROR_HANDLING=false
# drain pending terminal responses (OSC 11, CPR, etc.) left by gum
drain_terminal() {
  if [[ -t 0 ]]; then
    stty -echo 2>/dev/null || true
    while read -r -t 0.3 -n 1024 2>/dev/null; do :; done
    stty echo 2>/dev/null || true
  fi
  stty sane 2>/dev/null || true
}
# clear the banner/logo from screen on error
clear_logo() {
  printf '\033[H\033[2J'
}
catch_errors() {
  local exit_code=$?
  if [[ $ERROR_HANDLING == true ]]; then
    return
  fi
  ERROR_HANDLING=true
  set +eE
  drain_terminal
  echo
  clear_logo
  gum style --foreground 1 "JustBuntu installation stopped!"
  if [[ -n ${BASH_COMMAND:-} ]]; then
    gum style "Failed command: $BASH_COMMAND (exit code $exit_code)"
  fi
  echo
  # show last lines from the log for quick context
  if [[ -f ${JUSTBUNTU_INSTALL_LOG_FILE:-} ]]; then
    echo "Recent log output:"
    tail -10 "$JUSTBUNTU_INSTALL_LOG_FILE" | sed 's/\x1b\[[0-9;]*m//g' | while IFS= read -r line; do
      echo "  $line"
    done
    echo
  fi
  # options menu — loops until user retries or exits
  while true; do
    local choice
    choice=$(gum choose \
      "Retry installation" \
      "View full log" \
      "Exit" \
      --header "What would you like to do?" --height 6) || choice=""
    case "$choice" in
    "Retry installation")
      printf '\033[H\033[2J'
      exec bash -c "source $HOME/.local/share/justbuntu/provision/orchestrate.sh"
      ;;
    "View full log")
      less "$JUSTBUNTU_INSTALL_LOG_FILE" 2>/dev/null || tail -50 "$JUSTBUNTU_INSTALL_LOG_FILE"
      ;;
    *)
      exit 1
      ;;
    esac
  done
}
# exit handler — triggers error handling on non-zero exit
exit_handler() {
  local exit_code=$?
  if (( exit_code != 0 )) && [[ $ERROR_HANDLING != true ]]; then
    catch_errors
  fi
}
# set up traps
trap catch_errors ERR
trap 'exit 130' INT TERM
trap exit_handler EXIT
