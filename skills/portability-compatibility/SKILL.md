# Portability and Compatibility

## Overview

Write scripts that work across systems. Know where bash-specific features are used and when POSIX compliance matters.

**Confidence**: Verified via coding-style-guide repo, LinuxVox, and bashsupport.com just now.

## Shebang Choices

```bash
# Most portable — finds bash via PATH
#!/usr/bin/env bash

# Explicit path — faster but assumes bash location
#!/bin/bash

# POSIX shell only — maximum portability, no bash features
#!/bin/sh
```

**Self-challenge**: macOS ships bash 3.2 at `/bin/bash` (GPLv3 restrictions). Features like associative arrays (`declare -A`), `mapfile`, `readarray`, `coproc` require bash 4+. If targeting macOS, either avoid these or require `brew install bash`.

## Bash vs POSIX Feature Matrix

| Feature | Bash | POSIX `sh` |
|---------|------|-----------|
| `[[ ]]` test | ✅ | ❌ |
| Arrays (`arr=()`) | ✅ | ❌ |
| Associative arrays | ✅ (bash 4+) | ❌ |
| `$'...'` ANSI-C quoting | ✅ | ❌ |
| `${var,,}` / `${var^^}` case | ✅ (bash 4+) | ❌ |
| `set -o pipefail` | ✅ | ❌ |
| `local` keyword | ✅ (common extension) | ❌ (not POSIX) |
| `read -d` delimiter | ✅ | ❌ |
| Process substitution `<(cmd)` | ✅ | ❌ |

## Common Portability Pitfalls

### `echo` vs `printf`

`echo` behavior varies across systems (some interpret `-e`, `-n` flags; others don't). Use `printf` for predictable output:

```bash
# UNRELIABLE — behavior varies
echo -e "line1\nline2"

# RELIABLE — consistent everywhere
printf 'line1\nline2\n'
```

### `which` vs `command -v`

```bash
# UNRELIABLE — which output format varies, exit codes inconsistent
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

### Extended Regex in `sed`/`grep`

```bash
# GNU — -r for extended regex
sed -r 's/[0-9]+/X/g'
grep -E '[0-9]+'

# BSD — -E for extended regex
sed -E 's/[0-9]+/X/g'
grep -E '[0-9]+'

# Portable — stick to basic regex or use grep -E (POSIX)
grep -E '[0-9]+'     # POSIX-standardized flag
```

## Ubuntu-Specific Considerations

- Ubuntu 26.04 LTS ships bash 5.x — bash 4+ features are safe
- `wget` is preinstalled on Ubuntu desktop; `curl` is NOT preinstalled on Ubuntu desktop
- `curl` is preinstalled on Ubuntu server; `wget` is NOT preinstalled on Ubuntu server
- Ghostty is available in Ubuntu 26.04 LTS repos

**Confidence**: User confirmed from personal testing (wget/curl preinstall status).
