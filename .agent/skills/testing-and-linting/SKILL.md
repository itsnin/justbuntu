# Testing and Linting

## Linting with ShellCheck

ShellCheck catches 90% of common bash bugs. It is non-negotiable.

```bash
# Lint all shell scripts
find . -name "*.sh" -exec shellcheck {} +
```

### Common ShellCheck Warnings

| Code | Meaning | Fix |
|------|---------|-----|
| SC2086 | Double quote to prevent word splitting | `"$var"` instead of `$var` |
| SC2046 | Quote this to prevent word splitting | `"$(cmd)"` instead of `$(cmd)` |
| SC2162 | read without -r will mangle backslashes | `read -r` |
| SC2034 | Variable assigned but not used | Remove or use it |
| SC2181 | Check exit code directly | `if cmd; then` instead of `cmd; if [[ $? -eq 0 ]]` |
| SC2207 | Array from `$(...)` splits on IFS | Use `mapfile -t` or `while read` loop |

## Syntax Checking and Debugging

```bash
# Quick syntax check
bash -n script.sh

# In CI: check all scripts
find . -name "*.sh" -exec bash -n {} \;
```

### Debugging Modes

```bash
# Xtrace mode: print each command AFTER expansion (most useful)
bash -x script.sh

# Toggle within a script
set -x    # start tracing
set +x    # stop tracing
```

## Manual Testing Checklist

1. `bash -n` passes (syntax valid)
2. ShellCheck passes (or warnings are understood and suppressed with justification)
3. Test with `set -euo pipefail` active
4. Test error paths — what happens when a download fails?
5. Test with spaces in paths or filenames
6. Test with empty input
7. Test idempotency — run twice, second run should be safe
8. Test cleanup — interrupt with Ctrl+C, verify temp files are removed

## CI Pipeline Minimum

```yaml
- name: Syntax check
  run: find . -name "*.sh" -exec bash -n {} \;

- name: ShellCheck
  run: find . -name "*.sh" -exec shellcheck {} +
```
