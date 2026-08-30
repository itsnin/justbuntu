# Functions and Modularity

## Overview

Break scripts into small, single-responsibility functions. Each function does one thing well.

**Confidence**: Verified via bash-style-guide repo, coding-style-guide repo, and CursorRules just now.

## Function Declaration

```bash
# RIGHT — POSIX style, no 'function' keyword
validate_input() {
    local input="$1"
    # ...
}

# WRONG — non-POSIX 'function' keyword
function validate_input {
    # ...
}
```

## Function Design Principles

1. **Single responsibility** — one function does one thing
2. **Local variables** — all internal variables must be `local`
3. **Explicit inputs** — pass data as arguments, don't rely on global variables
4. **Return via exit code** — `return 0` for success, `return 1` for failure
5. **Output via stdout** — computed values go to stdout, caller captures with `$()`

```bash
# GOOD: explicit inputs, local variables, clear return
file_exists() {
    local file="$1"
    [[ -f "$file" ]]
}

if file_exists "/etc/passwd"; then
    echo "exists"
fi
```

## Avoid Global Variable Leaks

```bash
# DANGEROUS: variable leaks to global scope
count_items() {
    count=$(ls | wc -l)  # 'count' is now global!
    echo "$count"
}

# SAFE: local variable
count_items() {
    local count
    count=$(ls | wc -l)
    echo "$count"
}
```

## Sourcing Modular Files

Library scripts (collections of functions) should be sourced, not executed directly:

```bash
# At the top of a script that needs functions
source "$JUSTBUNTU_PATH/shell/bash/functions"
```

Library scripts should:
- Define only functions and variables
- NOT execute any logic at top level
- Document each function's purpose, inputs, outputs, and return codes

## Error Handling in Functions

```bash
# Return non-zero on failure, caller decides
download_file() {
    local url="$1"
    local dest="$2"

    if ! wget -q -O "$dest" "$url"; then
        echo "error: download failed: $url" >&2
        return 1
    fi
    return 0
}

# Caller handles the error
if ! download_file "$URL" "/tmp/data"; then
    echo "aborting" >&2
    exit 1
fi
```

**Self-challenge**: Can this function be understood and tested in isolation? If it depends on 5 global variables, it's not modular — pass them as arguments.
