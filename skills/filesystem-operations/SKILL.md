# Filesystem Operations

## Safe Temporary Files

Always use `mktemp`. Never predictable paths like `/tmp/script.tmp`.

```bash
TMP_DIR=$(mktemp -d)
TMP_FILE=$(mktemp)
cleanup() { rm -rf "$TMP_DIR" "$TMP_FILE"; }
trap cleanup EXIT ERR INT TERM
```

## Atomic File Writes

Never write directly to a file that another process might read. Write to a temp file, then rename atomically:

```bash
tmp_conf=$(mktemp)
echo "$new_content" > "$tmp_conf"
mv "$tmp_conf" /etc/config.conf
```

## File Locking

Prevent concurrent script instances:

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
for f in *.log; do process_log "$f"; done

# SAFE — use nullglob
shopt -s nullglob
for f in *.log; do process_log "$f"; done
shopt -u nullglob

# Or: use find
find . -name "*.log" -print0 | while IFS= read -r -d '' f; do
    process_log "$f"
done
```

## Path Validation

```bash
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
| `-s` | Non-empty |
| `-L` | Symbolic link |

## `cd` Safety

```bash
# DANGEROUS — if cd fails, subsequent commands run in wrong directory
cd /some/path
rm -rf *

# SAFE — abort on cd failure
cd /some/path || { echo "cd failed" >&2; exit 1; }
rm -rf *

# SAFER — run in subshell, parent directory unaffected
(
    cd /some/path || exit 1
    rm -rf *
)
```
