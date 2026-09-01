# Logging and Observability

## Overview

Make scripts observable with structured logging. Know what happened, when, and at what severity.

**Confidence**: Verified via Tirinfo logging guide, LobeHub defensive patterns, and general best practices just now.

## Log Levels

Use standard severity levels:

| Level | Purpose | Example |
|-------|---------|---------|
| `DEBUG` | Detailed diagnostic info | "variable x = 42" |
| `INFO` | Normal operation | "installing package: btop" |
| `WARN` | Unexpected but recoverable | "download failed, using cached version" |
| `ERROR` | Failure that prevents operation | "cannot reach package repository" |

## Structured Logging Function

```bash
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local levels=(DEBUG INFO WARN ERROR)
    local current_idx=-1
    local msg_idx=-1

    for i in "${!levels[@]}"; do
        [[ "${levels[$i]}" == "$LOG_LEVEL" ]] && current_idx=$i
        [[ "${levels[$i]}" == "$level" ]] && msg_idx=$i
    done

    [[ $msg_idx -ge $current_idx ]] || return 0

    case "$level" in
        ERROR) printf '[%s] [%s] %s\n' "$timestamp" "$level" "$message" >&2 ;;
        *)     printf '[%s] [%s] %s\n' "$timestamp" "$level" "$message" ;;
    esac
}

log DEBUG "starting provisioning"
log INFO "installing btop"
log WARN "gum not found, will install"
log ERROR "download failed for $url"
```

## Log to File and Terminal

```bash
LOG_FILE="/var/log/justbuntu-install.log"

# Redirect all output to both terminal and log file
exec > >(tee -a "$LOG_FILE") 2>&1
```

## Verbosity Control

```bash
VERBOSE="${VERBOSE:-0}"

verbose_echo() {
    [[ "$VERBOSE" -eq 1 ]] && echo "$*"
}

verbose_echo "detailed progress information..."
```

## Command Output Capture

```bash
# Capture output and exit code separately
output=$(sudo apt install -y btop 2>&1)
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    log ERROR "apt install failed (exit $exit_code): $output"
    exit 1
fi
```

## What NOT to Log

- **Secrets, passwords, API keys** — redact or mask
- **Personal data** — emails, names, phone numbers
- **Large binary output** — log a summary instead

**Self-challenge**: If this script failed silently in production, would the logs tell you exactly why? If not, add more logging.
