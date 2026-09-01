#!/bin/bash
# install logging — duplicates all terminal output to a log file.
# uses process substitution so sourced scripts inherit the redirection.
JUSTBUNTU_INSTALL_LOG_FILE="/var/log/justbuntu-install.log"
start_install_log() {
  sudo touch "$JUSTBUNTU_INSTALL_LOG_FILE"
  sudo chmod 666 "$JUSTBUNTU_INSTALL_LOG_FILE"
  export JUSTBUNTU_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  echo "=== JustBuntu Installation Started: $JUSTBUNTU_START_TIME ===" >>"$JUSTBUNTU_INSTALL_LOG_FILE"
  # redirect all stdout and stderr to both terminal and log file
  exec > >(tee -a "$JUSTBUNTU_INSTALL_LOG_FILE") 2>&1
}
stop_install_log() {
  if [[ -n ${JUSTBUNTU_INSTALL_LOG_FILE:-} && -n ${JUSTBUNTU_START_TIME:-} ]]; then
    local end_time mins secs start_epoch end_epoch duration
    end_time=$(date '+%Y-%m-%d %H:%M:%S')
    start_epoch=$(date -d "$JUSTBUNTU_START_TIME" +%s)
    end_epoch=$(date -d "$end_time" +%s)
    duration=$((end_epoch - start_epoch))
    mins=$((duration / 60))
    secs=$((duration % 60))
    {
      echo "=== JustBuntu Installation Completed: $end_time ==="
      echo ""
      echo "=== Installation Time Summary ==="
      echo "JustBuntu: ${mins}m ${secs}s"
      echo "================================="
    } >>"$JUSTBUNTU_INSTALL_LOG_FILE"
  fi
}
