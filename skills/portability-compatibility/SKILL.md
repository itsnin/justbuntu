# Portability and Compatibility

## Shebang Choices

```bash
#!/usr/bin/env bash    # Most portable — finds bash via PATH
#!/bin/bash            # Explicit path — faster but assumes bash location
#!/bin/sh              # POSIX shell only — maximum portability, no bash features
```

## Bash vs POSIX Feature Matrix

| Feature | Bash | POSIX `sh` |
|---------|------|-----------|
| `[[ ]]` test | Yes | No |
| Arrays | Yes | No |
| Associative arrays | Yes (bash 4+) | No |
| `$'...'` ANSI-C quoting | Yes | No |
| `${var,,}` / `${var^^}` case | Yes (bash 4+) | No |
| `set -o pipefail` | Yes | No |
| `local` keyword | Yes (common extension) | No |
| `read -d` delimiter | Yes | No |
| Process substitution `<(cmd)` | Yes | No |

## Common Portability Pitfalls

### `echo` vs `printf`

`echo` behavior varies across systems. Use `printf` for predictable output:

```bash
printf 'line1\nline2\n'
```

### `which` vs `command -v`

```bash
# UNRELIABLE — which output format varies
if which curl; then ...

# RELIABLE — POSIX, consistent behavior
if command -v curl >/dev/null 2>&1; then ...
```

### `sed` In-Place Editing

```bash
# GNU sed (Linux)
sed -i 's/old/new/' file

# BSD sed (macOS) — requires backup extension
sed -i '' 's/old/new/' file

# Portable — use a backup file and clean up
sed -i.bak 's/old/new/' file && rm -f file.bak
```

## Ubuntu-Specific Considerations

- Ubuntu 26.04 LTS ships bash 5.x — bash 4+ features are safe
- `wget` is preinstalled on Ubuntu desktop; `curl` is NOT preinstalled on Ubuntu desktop
- `curl` is preinstalled on Ubuntu server; `wget` is NOT preinstalled on Ubuntu server
- Ghostty is available in Ubuntu 26.04 LTS repos
