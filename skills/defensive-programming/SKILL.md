# Defensive Programming

## Overview

Write scripts that anticipate failure, validate assumptions, and degrade gracefully.

**Confidence**: Verified via LobeHub defensive patterns, bash-style-guide repo, and coding-style-guide repo just now.

## Core Defensive Principles

1. **Treat all input as untrusted** — arguments, environment variables, file contents, command output
2. **Validate early, fail clearly** — check preconditions before doing work
3. **Design for idempotency** — safe to run multiple times
4. **Support dry-run mode** — show what would change without changing anything
5. **Clean up after yourself** — use `mktemp` + `trap` for temp files
6. **Check dependencies exist** — verify required commands before using them

## Input Validation

```bash
# Validate argument count
if [[ $# -lt 2 ]]; then
    echo "usage: $0 <source> <destination>" >&2
    exit 1
fi

# Validate file existence
if [[ ! -f "$source_file" ]]; then
    echo "error: source file not found: $source_file" >&2
    exit 1
fi

# Validate numeric input
if ! [[ "$count" =~ ^[0-9]+$ ]]; then
    echo "error: count must be a positive integer, got: $count" >&2
    exit 1
fi

# Validate against allowlist (safer than blocklist)
case "$action" in
    install|remove|update) ;;
    *) echo "error: invalid action: $action" >&2; exit 1 ;;
esac
```

## Dependency Checking

```bash
# Use command -v, NOT which
if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required but not installed" >&2
    exit 1
fi
```

## Safe Temporary Files

```bash
# Create temp directory with automatic cleanup
TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT ERR INT TERM

# Or for a single file
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT
```

**Self-challenge**: Never use predictable temp paths like `/tmp/script.tmp`. They are race-condition vulnerabilities and can be symlinked to overwrite important files.

## Dry-Run Pattern

```bash
DRY_RUN="${DRY_RUN:-0}"

run_cmd() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

run_cmd sudo apt install -y btop
```

## Idempotency Checks

```bash
# Only install if not already present
if ! command -v btop >/dev/null 2>&1; then
    sudo apt install -y btop
fi

# Only create directory if it doesn't exist
[[ -d "$target_dir" ]] || mkdir -p "$target_dir"
```

## Desktop Entries Need Absolute Paths

Desktop-launched applications inherit their environment from the systemd user session, NOT from .bashrc. Commands that rely on PATH entries set in shell config files will fail with "command not found" or "exec: AccessDenied." Always use absolute paths in .desktop Exec= lines.

Bad: Exec=justbuntu
Good: Exec=/home/user/.local/share/justbuntu/bin/justbuntu
