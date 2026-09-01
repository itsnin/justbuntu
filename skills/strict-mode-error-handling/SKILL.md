# Strict Mode and Error Handling

## Overview

Transform bash from a forgiving interpreter into a strict execution environment. Fail fast, fail clearly.

**Confidence**: Verified via Linuxize, Kinda Technical, coding-style-guide repos, and ABS Guide (Chapters 33, Appendix E) just now.

## Strict Mode Flags

Every script must start with:

```bash
set -euo pipefail
```

| Flag | Name | Behavior |
|------|------|----------|
| `-e` / `errexit` | Exit on error | Script exits immediately if any command returns non-zero |
| `-u` / `nounset` | Error on undefined | Treat unset variables as errors and exit |
| `-o pipefail` | Pipe failure | Pipeline returns exit status of last failing command |

### Additional Useful Options

| Flag | Name | Effect |
|------|------|--------|
| `-C` / `noclobber` | No overwrite | Prevent accidental file overwriting via redirection. Override with `>\|`. |
| `-f` / `noglob` | No globbing | Disable filename expansion (wildcards). Useful when processing user input that might contain `*` or `?`. |
| `-E` / `errtrace` | ERR trace | ERR traps are inherited by shell functions. Critical when using `trap ... ERR` for error handling. |
| `-a` / `allexport` | Auto-export | Export all defined variables automatically. |
| `-v` / `verbose` | Verbose | Print each command to stderr before executing. Useful for debugging. |
| `-x` / `xtrace` | Trace | Print expanded commands to stderr. Indispensable debugging tool. |

Enable from shebang: `#!/bin/bash -x`
Disable within script: `set +x`

### Critical Caveats for `set -e`

`set -e` does NOT trigger when:
- Command is part of an `if` / `while` / `until` condition
- Command is part of `&&` or `||` list (except the final command)
- Command is in a negated `!` expression
- Command output is captured via `$(...)` or backticks and the result is used in a conditional

**Self-challenge**: Are you relying on `set -e` to catch errors in a pipeline? Without `pipefail`, only the LAST command's exit status matters. Always use `set -o pipefail`.

## Reserved Exit Codes

**Verified via ABS Guide Appendix E just now**. These codes have special meanings and should NOT be used for user-defined errors:

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Catchall for general errors |
| `2` | Misuse of shell builtins |
| `126` | Command invoked cannot execute (permission problem) |
| `127` | "Command not found" |
| `128+n` | Fatal error signal "n" |
| `130` | Script terminated by Ctrl-C (128 + 2) |
| `255` | Exit status out of range |

**Convention**: User-defined exit codes should use range **64–113** (conforming to C's `sysexits.h` proposal). This avoids confusion with reserved codes. **Label: Author's proposal in ABS Guide, not verified as universal industry standard**.

```bash
# Example: named error codes
E_BADARGS=65
E_NOTFOUND=66
E_NOPERM=67

if [[ $# -eq 0 ]]; then
    echo "error: missing arguments" >&2
    exit $E_BADARGS
fi
```

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

## Error Messaging

Send errors to stderr, not stdout:

```bash
echo "error: file not found: $file" >&2
return 1
```
