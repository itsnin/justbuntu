# Scripting Style Guide

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

- Indentation: 2 spaces. Never tabs.
- Line length: Maximum 80 characters where practical.
- Semicolons: Avoid unless required in control statements.
- `then` on same line as `if`: `if [[ ... ]]; then`
- `do` on same line as `while` / `for`: `while [[ ... ]]; do`

## Functions

- Do NOT use the `function` keyword. Use POSIX-style declaration.
- All variables inside functions must be `local`.
- Return via exit codes (0 = success, non-zero = failure), not stdout for status.

## Script Header

Every script must start with:

```bash
#!/usr/bin/env bash
#
# script-name.sh — one-line description of purpose
#
set -euo pipefail
```

## When to Use Bash

Good for: simple automation under 200 lines, system administration, CI/CD pipeline steps, environment setup, file manipulation.

Avoid for: complex business logic, data processing, API clients, JSON/YAML parsing, scripts requiring unit testing, scripts over 200 lines. Use Python or Go instead.

## Interactive Flow: All Choices Upfront

Never interleave installation or removal actions with interactive prompts. Ask all questions first, gather all preferences into environment variables, then execute all system changes. This gives the user a clean decision phase followed by an uninterrupted execution phase.
