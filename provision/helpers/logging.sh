#!/bin/bash
# Install logging — duplicates all terminal output to a log file.
# Uses process substitution so sourced scripts inherit the redirection.
JUSTBUNTU_INSTALL_LOG_FILE="/var/log/justbuntu-install.log"
start_install_log() {
  sudo touch "$JUSTBUNTU_INSTALL_LOG_FILE"
  sudo chmod 666 "$JUSTBUNTU_INSTALL_LOG_FILE"
  JUSTBUNTU_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  export JUSTBUNTU_START_TIME
  echo "=== JustBuntu Installation Started: $JUSTBUNTU_START_TIME ===" >>"$JUSTBUNTU_INSTALL_LOG_FILE"
  # Redirect all stdout and stderr to both terminal and log file
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
# Run a provisioning script with log markers and CURRENT_SCRIPT tracking.
# Sources the script so environment changes persist between scripts.
run_script() {
  local script="$1"
  local script_name
  script_name=$(basename "$script")
  export CURRENT_SCRIPT="$script_name"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $script_name"
  source "$script"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Completed: $script_name"
}
