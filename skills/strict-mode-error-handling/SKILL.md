# Strict Mode and Error Handling

## Overview

Transform bash from a forgiving interpreter into a strict execution environment. Fail fast, fail clearly.

**Confidence**: Verified via Linuxize, Kinda Technical, coding-style-guide repos just now.

## Strict Mode Flags

Every script must start with:

```bash
set -euo pipefail
```

| Flag | Meaning | Behavior |
|------|---------|----------|
| `-e` / `errexit` | Exit on error | Script exits immediately if any command returns non-zero |
| `-u` / `nounset` | Error on undefined | Treat unset variables as errors and exit |
| `-o pipefail` | Pipe failure awareness | Pipeline returns exit status of last failing command |

### Critical Caveats for `set -e`

`set -e` does NOT trigger when:
- Command is part of an `if` / `while` / `until` condition
- Command is part of `&&` or `||` list (except the final command)
- Command is in a negated `!` expression
- Command output is captured via `$(...)` or backticks and the result is used in a conditional

**Self-challenge**: Are you relying on `set -e` to catch errors in a pipeline? Without `pipefail`, only the LAST command's exit status matters. Always use `set -o pipefail`.

## Trap for Cleanup

Use `trap` to guarantee cleanup runs on exit, error, or interrupt:

```bash
TMP_DIR=""
cleanup() {
    local exit_code=$?
    [[ -n "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
    exit $exit_code
}
trap cleanup EXIT ERR INT TERM
```

## Graceful Degradation

For commands that may legitimately fail without aborting the entire script:

```bash
# Use || true for non-critical operations
sudo apt autoremove -y 2>/dev/null || true

# Use if/then for conditional paths
if ! command -v ghostty >/dev/null 2>&1; then
    echo "ghostty not found, skipping default terminal setup"
    return 0
fi

# Use || echo for warning messages
sudo apt install -y ./package.deb || echo "package install failed (continuing)"
```

## Exit Codes

- `0` = success
- `1` = general error
- `2` = misuse of shell builtins
- Use specific non-zero codes for specific error conditions when callers need to distinguish

## Error Messaging

Send errors to stderr, not stdout:

```bash
echo "error: file not found: $file" >&2
return 1
```
