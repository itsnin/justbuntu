# Scripting Style Guide

## Overview

Definitive standards for writing bash scripts that are safe, predictable, and maintainable. These rules are verified against the bash-style-guide (Dave Eddy / YSAP series) and coding-style-guide (Tyler Dukes).

**Confidence**: Verified via cloned GitHub repos just now (bash-style-guide, coding-style-guide)

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Variables | `snake_case` lowercase | `user_count`, `max_retries` |
| Constants | `UPPER_SNAKE_CASE` | `readonly MAX_RETRIES=3` |
| Functions | `snake_case` descriptive | `validate_input()`, `cleanup_temp()` |
| Script files | `kebab-case.sh` | `deploy-app.sh`, `backup-system.sh` |
| Executables in PATH | `kebab-case` no extension | `justbuntu` |
| Environment vars | `UPPER_SNAKE_CASE` | `JUSTBUNTU_PATH`, `HOME` |

## Formatting

- **Indentation**: 2 spaces. Never tabs.
- **Line length**: Maximum 80 characters.
- **Semicolons**: Avoid unless required in control statements.
- **`then`** on same line as **`if`**: `if [[ ... ]]; then`
- **`do`** on same line as **`while`** / **`for`**: `while [[ ... ]]; do`

```bash
# right
if [[ -n "$name" ]]; then
    echo "hello $name"
fi

# wrong
if [[ -n "$name" ]]
then
    echo "hello $name"
fi
```

## Functions

- Do NOT use the `function` keyword. Use POSIX-style declaration.
- All variables inside functions must be `local`.
- Return via exit codes (0 = success, non-zero = failure), not stdout for status.

```bash
# right
compute_sum() {
    local a="$1"
    local b="$2"
    echo $((a + b))
}

# wrong
function compute_sum {
    result=$((a + b))  # result leaks to global scope
}
```

## Script Header

Every script must start with:

```bash
#!/usr/bin/env bash
#
# script-name.sh — one-line description of purpose
#
# usage: ./script-name.sh [options] <arguments>
#
set -euo pipefail
```

## When to Use Bash

✅ **Good**: Simple automation (< 200 lines), system administration, CI/CD pipeline steps, environment setup, file manipulation.

❌ **Avoid**: Complex business logic, data processing, API clients, JSON/YAML parsing, scripts requiring unit testing, scripts > 200 lines. Use Python/Go instead.

**Self-challenge**: Is this script growing beyond 200 lines? If yes, consider whether a higher-level language would be more maintainable.
