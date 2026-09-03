# Logging and Observability

## Log Levels

Standard severity levels: DEBUG, INFO, WARN, ERROR.

## Structured Logging Function

```bash
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level="$1"; shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local levels=(DEBUG INFO WARN ERROR)
    local current_idx=-1 msg_idx=-1

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
```

## Log to File and Terminal

```bash
LOG_FILE="/var/log/justbuntu-install.log"
exec > >(tee -a "$LOG_FILE") 2>&1
```

## Verbosity Control

```bash
VERBOSE="${VERBOSE:-0}"
verbose_echo() {
    [[ "$VERBOSE" -eq 1 ]] && echo "$*"
}
```

## Command Output Capture

```bash
output=$(sudo apt install -y btop 2>&1)
exit_code=$?
```

## What NOT to Log

- Secrets, passwords, API keys — redact or mask
- Personal data — emails, names, phone numbers
- Large binary output — log a summary instead
