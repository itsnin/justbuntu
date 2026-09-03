# Conditionals and Control Flow

## `[[ ]]` vs `[ ]`

| Feature | `[[ ... ]]` (bash) | `[ ... ]` (POSIX) |
|---------|-------------------|-------------------|
| Word splitting | No — variables safe unquoted | Yes — must quote variables |
| Glob matching | `==` with right-side patterns | Not supported |
| Regex matching | `=~` operator | Not supported |
| Logical operators | `&&` and `\|\|` inside | `-a` and `-o` inside |
| Portability | Bash-only | All POSIX shells |

## Common Pitfalls

### `=` vs `==` vs `-eq`

```bash
# String comparison
if [[ "$a" == "$b" ]]; then ...

# Numeric comparison
if [[ "$count" -gt 5 ]]; then ...

# DANGEROUS — numeric comparison as string
if [[ "$count" > 5 ]]; then     # WRONG — lexicographic comparison
```

### Empty Variable Testing

```bash
# RIGHT — explicit and clear
if [[ -z "$var" ]]; then
    echo "var is empty or unset"
fi

# DANGEROUS — breaks if var is unset under set -u
if [[ "$var" == "" ]]; then ...
```

## Case Statements

Use `case` for multi-way branching — cleaner than chained `if/elif`:

```bash
case "$action" in
    install) install_package "$1" ;;
    remove|uninstall) remove_package "$1" ;;
    *) echo "error: unknown action" >&2; exit 1 ;;
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
```

## Pipeline Subshell Gotcha

A pipeline creates a subshell, so variable changes inside don't propagate:

```bash
# DANGEROUS — last_line stays empty
last_line=""
your_command | while read -r line; do
    last_line="$line"
done

# SAFE — process substitution keeps everything in one shell
last_line=""
while read -r line; do
    last_line="$line"
done < <(your_command)
```
