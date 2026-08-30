# Conditionals and Control Flow

## Overview

Write clear, correct conditionals and loops. Avoid common pitfalls.

**Confidence**: Verified via bash-style-guide repo, coding-style-guide repo just now.

## Test Constructs: `[[ ]]` vs `[ ]`

| Feature | `[[ ... ]]` (bash) | `[ ... ]` (POSIX) |
|---------|-------------------|-------------------|
| Word splitting | No — variables safe unquoted | Yes — must quote variables |
| Glob matching | `==` with right-side patterns | Not supported |
| Regex matching | `=~` operator | Not supported |
| Logical operators | `&&` and `\|\|` inside | `-a` and `-o` inside |
| Portability | Bash-only | All POSIX shells |

```bash
# Bash preferred — safer, more capable
if [[ -n "$name" && "$name" == a* ]]; then
    echo "starts with a"
fi

# POSIX — quote everything
if [ -n "$name" ] && [ "$name" = "alice" ]; then
    echo "hello alice"
fi
```

## Common Pitfalls

### `=` vs `==` vs `-eq`

```bash
# String comparison: = or == (== is bashism)
if [[ "$a" == "$b" ]]; then ...

# Numeric comparison: -eq, -ne, -lt, -le, -gt, -ge
if [[ "$count" -gt 5 ]]; then ...

# DANGEROUS — numeric comparison as string
if [[ "$count" > 5 ]]; then     # WRONG — lexicographic comparison!
if [[ "$count" -gt 5 ]]; then    # RIGHT — numeric comparison
```

### Empty Variable Testing

```bash
# RIGHT — explicit and clear
if [[ -z "$var" ]]; then
    echo "var is empty or unset"
fi

if [[ -n "$var" ]]; then
    echo "var is set and non-empty"
fi

# DANGEROUS — breaks if var is unset under set -u
if [[ "$var" == "" ]]; then ...
```

## Case Statements

Use `case` for multi-way branching — cleaner than chained `if/elif`:

```bash
case "$action" in
    install)
        install_package "$1"
        ;;
    remove|uninstall)
        remove_package "$1"
        ;;
    update|upgrade)
        update_package "$1"
        ;;
    *)
        echo "error: unknown action: $action" >&2
        exit 1
        ;;
esac
```

## Loop Patterns

```bash
# Iterate over lines safely
while IFS= read -r line; do
    process_line "$line"
done < "$input_file"

# Iterate over array safely
for item in "${items[@]}"; do
    process_item "$item"
done

# Iterate over arguments
for arg in "$@"; do
    process_arg "$arg"
done

# DANGEROUS — pipeline creates subshell, variable changes don't propagate
last_line=""
your_command | while read -r line; do
    last_line="$line"
done
# $last_line is still "" here!

# SAFE — use process substitution to avoid subshell
while read -r line; do
    last_line="$line"
done < <(your_command)
```

**Self-challenge**: In a `while read` loop inside a pipeline, does the loop body run in a subshell? Yes — variable changes won't propagate. Use process substitution `< <(cmd)` instead.
