# Testing and Linting

## Overview

Catch bugs before they reach production. Lint everything, test what matters.

**Confidence**: Verified via bash-style-guide repo, CursorRules, and general DevOps best practices just now.

## Linting with ShellCheck

**ShellCheck is non-negotiable.** It catches 90% of common bash bugs.

```bash
# Install
sudo apt install -y shellcheck

# Lint a single file
shellcheck script.sh

# Lint all shell scripts in a project
find . -name "*.sh" -exec shellcheck {} +

# CI integration (GitHub Actions)
- name: ShellCheck
  run: find . -name "*.sh" -exec shellcheck {} +
```

### Common ShellCheck Warnings to Understand

| Code | Meaning | Fix |
|------|---------|-----|
| SC2086 | Double quote to prevent word splitting | `"$var"` instead of `$var` |
| SC2046 | Quote this to prevent word splitting | `"$(cmd)"` instead of `$(cmd)` |
| SC2162 | read without -r will mangle backslashes | `read -r` |
| SC2034 | Variable is assigned but not used | Remove or use it |
| SC2181 | Check exit code directly | `if cmd; then` instead of `cmd; if [[ $? -eq 0 ]]` |
| SC2207 | Array from `$(...)` splits on IFS | Use `mapfile -t` or `while read` loop |

## Syntax Checking

```bash
# Quick syntax check — catches parse errors
bash -n script.sh

# In CI: check all scripts
find . -name "*.sh" -exec bash -n {} \;
```

## Unit Testing with Bats

Bats (Bash Automated Testing System) for unit tests:

```bash
# Install
sudo apt install -y bats

# test_example.bats
@test "addition works" {
    result=$((2 + 2))
    [[ "$result" -eq 4 ]]
}

@test "file_exists returns 0 for existing file" {
    source ./functions.sh
    file_exists "/etc/passwd"
}

# Run tests
bats test_example.bats
```

## Manual Testing Checklist

Before considering a script "done":

1. ✅ `bash -n` passes (syntax valid)
2. ✅ ShellCheck passes (or warnings are understood and suppressed with justification)
3. ✅ Test with `set -euo pipefail` active
4. ✅ Test error paths — what happens when a download fails?
5. ✅ Test with spaces in paths/filenames
6. ✅ Test with empty input
7. ✅ Test idempotency — run twice, second run should be safe
8. ✅ Test cleanup — interrupt with Ctrl+C, verify temp files are removed

## CI Pipeline Minimum

```yaml
- name: Syntax check
  run: find . -name "*.sh" -exec bash -n {} \;

- name: ShellCheck
  run: find . -name "*.sh" -exec shellcheck {} +
```

**Self-challenge**: Would you trust this script to run unattended on a production system? If not, what test or check is missing?
