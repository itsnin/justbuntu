# Variables and Quoting

## Variable Declaration

```bash
name="value"        # RIGHT — no spaces around =
name = "value"      # WRONG

readonly MAX_RETRIES=3

process_file() {
    local file="$1"  # local inside functions
}
```

## Variable Expansion

| Form | Purpose |
|------|---------|
| `"$var"` | Expand value, quoted to prevent word splitting |
| `${var}` | Explicit delimiter — `${var}suffix` |
| `${var:-default}` | Use default if unset or empty |
| `${var:=default}` | Use default AND assign to var |
| `${var:?error}` | Exit with error if unset or empty |
| `${var#prefix}` | Remove shortest prefix |
| `${var##prefix}` | Remove longest prefix |
| `${var%suffix}` | Remove shortest suffix |
| `${var%%suffix}` | Remove longest suffix |
| `${#var}` | String length |
| `${var,,}` | Lowercase |
| `${var^^}` | Uppercase |

## The Quoting Rules

Rule 1: Quote ALL variable expansions unless you explicitly want word splitting and glob expansion.

Rule 2: Single quotes `'...'` — literal, no expansion. Use for fixed strings.

Rule 3: Double quotes `"..."` — expand `$`, backticks, and `\`. Use for most variable interpolations.

Rule 4: ANSI-C quoting `$'...'` — interpret escape sequences.

## When NOT to Quote

- Inside `[[ ... ]]` conditionals (pattern matching on the right side of `=~` or `==` with globs)
- When you explicitly want word splitting (rare — use arrays instead)

## Arrays Over Word Splitting

```bash
# DANGEROUS — word splitting breaks paths with spaces
files="file1.txt my document.txt"
for f in $files; do ...  # Iterates: file1.txt, my, document.txt

# SAFE — arrays preserve elements
files=("file1.txt" "my document.txt")
for f in "${files[@]}"; do ...  # Iterates correctly
```
