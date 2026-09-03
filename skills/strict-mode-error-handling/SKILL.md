# Strict Mode and Error Handling

## Strict Mode Flags

Every script must start with:

```bash
set -euo pipefail
```

| Flag | Behavior |
|------|----------|
| `-e` / `errexit` | Exit immediately if any command returns non-zero |
| `-u` / `nounset` | Treat unset variables as errors and exit |
| `-o pipefail` | Pipeline returns exit status of last failing command |

### Additional Useful Options

| Flag | Effect |
|------|--------|
| `-C` / `noclobber` | Prevent accidental file overwriting via redirection |
| `-E` / `errtrace` | ERR traps inherited by shell functions. Critical for error handling |
| `-x` / `xtrace` | Print expanded commands to stderr. Indispensable debugging tool |

### `set -e` Caveats

`set -e` does NOT trigger when:
- Command is part of an `if` / `while` / `until` condition
- Command is part of `&&` or `||` list (except the final command)
- Command is in a negated `!` expression
- Command output is captured via `$(...)` and used in a conditional

## Reserved Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Catchall for general errors |
| `2` | Misuse of shell builtins |
| `126` | Command invoked cannot execute (permission problem) |
| `127` | Command not found |
| `128+n` | Fatal error signal n |
| `130` | Script terminated by Ctrl+C (128 + 2) |
| `255` | Exit status out of range |

User-defined exit codes should use range 64-113.

## Trap for Cleanup

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

```bash
# Non-critical operations
sudo apt autoremove -y 2>/dev/null || true

# Conditional paths
if ! command -v ghostty >/dev/null 2>&1; then
    echo "ghostty not found, skipping"
    return 0
fi
```

## Error Messaging

Send errors to stderr, not stdout:

```bash
echo "error: file not found: $file" >&2
return 1
```
