# Filesystem Operations

## Overview

Safe, predictable file and directory manipulation. Avoid race conditions, path traversal, and data loss.

**Confidence**: Verified via defensive programming patterns and general Unix best practices just now.

## Safe Temporary Files

```bash
# ALWAYS use mktemp — never predictable paths like /tmp/script.tmp
TMP_DIR=$(mktemp -d)
TMP_FILE=$(mktemp)

# ALWAYS clean up with trap
cleanup() { rm -rf "$TMP_DIR" "$TMP_FILE"; }
trap cleanup EXIT ERR INT TERM
```

**Self-challenge**: If your script uses `/tmp/anything-fixed`, you have a security vulnerability. An attacker can pre-create a symlink at that path pointing to `/etc/passwd` or similar. Use `mktemp`.

## Atomic File Writes

Never write directly to a file that another process might read. Write to a temp file, then rename atomically:

```bash
# DANGEROUS — partial writes visible to readers
echo "$new_content" > /etc/config.conf

# SAFE — atomic rename, readers see complete file or old file
tmp_conf=$(mktemp)
echo "$new_content" > "$tmp_conf"
mv "$tmp_conf" /etc/config.conf
```

## File Locking

Prevent concurrent script instances from corrupting data:

```bash
LOCK_FILE="/var/lock/my_script.lock"

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
    echo "another instance is running" >&2
    exit 1
fi
```

## Safe Globbing

```bash
# DANGEROUS — if no files match, glob becomes literal string "*.log"
for f in *.log; do
    process_log "$f"  # Tries to process file literally named "*.log"
done

# SAFE — check for existence first
shopt -s nullglob
for f in *.log; do
    process_log "$f"
done
shopt -u nullglob

# Or: use find
find . -name "*.log" -print0 | while IFS= read -r -d '' f; do
    process_log "$f"
done
```

## Path Validation

```bash
# Resolve to absolute path and validate it's within expected directory
target=$(realpath -m "$user_input")
expected_prefix="/var/data/"

if [[ "$target" != "$expected_prefix"* ]]; then
    echo "error: path traversal detected" >&2
    exit 1
fi
```

## File Existence Checks

| Test | Meaning |
|------|---------|
| `-e` | Exists (any type) |
| `-f` | Regular file |
| `-d` | Directory |
| `-r` | Readable |
| `-w` | Writable |
| `-x` | Executable |
| `-s` | Non-empty (size > 0) |
| `-L` | Symbolic link |

## `cd` Safety

```bash
# DANGEROUS — if cd fails, subsequent commands run in wrong directory
cd /some/path
rm -rf *   # Could run in /home/user or / !

# SAFE — abort on cd failure
cd /some/path || { echo "cd failed" >&2; exit 1; }
rm -rf *

# SAFER — run in subshell, parent directory unaffected
(
    cd /some/path || exit 1
    rm -rf *
)
```

**Self-challenge**: If `cd` fails, what happens to the next command? If it's a destructive operation, you must handle the failure explicitly.
