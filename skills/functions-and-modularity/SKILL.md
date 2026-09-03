# Functions and Modularity

## Function Declaration

```bash
# RIGHT — POSIX style, no 'function' keyword
validate_input() {
    local input="$1"
}

# WRONG — non-POSIX 'function' keyword
function validate_input { }
```

## Critical Rules

1. Functions may NOT be empty. Even comments-only functions cause syntax errors. Use `:` (null command) as a placeholder.
2. Definition must precede call. No forward declarations in bash.
3. Nested functions are possible but not recommended.

## Function Design Principles

1. Single responsibility — one function does one thing
2. Local variables — all internal variables must be `local`
3. Explicit inputs — pass data as arguments, don't rely on global variables
4. Return via exit code — `return 0` for success, `return 1` for failure
5. Output via stdout — computed values go to stdout, caller captures with `$()`

## Avoid Global Variable Leaks

```bash
# DANGEROUS: variable leaks to global scope
count_items() {
    count=$(ls | wc -l)  # 'count' is now global
}

# SAFE: local variable
count_items() {
    local count
    count=$(ls | wc -l)
}
```

## Sourcing Modular Files

Library scripts should be sourced, not executed directly. They should define only functions and variables, not execute logic at top level.

## Error Handling in Functions

Return non-zero on failure, caller decides:

```bash
download_file() {
    local url="$1" dest="$2"
    if ! wget -q -O "$dest" "$url"; then
        echo "error: download failed: $url" >&2
        return 1
    fi
    return 0
}
```
