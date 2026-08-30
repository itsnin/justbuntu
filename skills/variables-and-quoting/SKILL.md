# Variables and Quoting

## Overview

Master variable declaration, scope, and the single most important bash skill: quoting correctly.

**Confidence**: Verified via coding-style-guide repo, bash-style-guide repo, and Linuxize best practices just now.

## Variable Declaration

```bash
# Assignment: NO spaces around =
name="value"        # RIGHT
name = "value"      # WRONG — tries to run command 'name'

# Use readonly for constants
readonly MAX_RETRIES=3
readonly API_URL="https://api.example.com"

# Use local inside functions
process_file() {
    local file="$1"
    local count=0
    # ...
}

# Use declare for typed variables (bash 4+)
declare -i number=42       # integer
declare -a items=()        # array
declare -A config=()       # associative array (bash 4+)
```

## Variable Expansion

| Form | Purpose |
|------|---------|
| `"$var"` | Expand value, quoted to prevent word splitting |
| `${var}` | Explicit delimiter — `${var}suffix` |
| `${var:-default}` | Use default if unset or empty |
| `${var:=default}` | Use default AND assign to var |
| `${var:?error message}` | Exit with error if unset or empty |
| `${var#prefix}` | Remove shortest prefix |
| `${var##prefix}` | Remove longest prefix |
| `${var%suffix}` | Remove shortest suffix |
| `${var%%suffix}` | Remove longest suffix |
| `${#var}` | String length |
| `${var,,}` | Lowercase |
| `${var^^}` | Uppercase |

## The Quoting Rules

**Rule 1: Quote ALL variable expansions unless you explicitly want word splitting and glob expansion.**

```bash
# RIGHT — quoted, safe
cp "$source" "$dest"
grep "$pattern" "$file"

# WRONG — unquoted, dangerous
cp $source $dest
grep $pattern $file
```

**Rule 2: Single quotes `'...'`** — literal, no expansion. Use for fixed strings.

```bash
echo 'The variable $HOME is not expanded here'
```

**Rule 3: Double quotes `"...""`** — expand `$`, backticks, and `\`. Use for most variable interpolations.

**Rule 4: ANSI-C quoting `$'...'`** — interpret escape sequences.

```bash
printf $'line1\nline2\n'
```

## When NOT to Quote

- Inside `[[ ... ]]` conditionals (pattern matching on the right side of `=~` or `==` with globs)
- When you explicitly want word splitting (rare — use arrays instead)
- When you explicitly want glob expansion (rare)

## Arrays Over Word Splitting

```bash
# DANGEROUS — word splitting breaks paths with spaces
files="file1.txt my document.txt"
for f in $files; do ...  # Iterates: file1.txt, my, document.txt

# SAFE — arrays preserve elements
files=("file1.txt" "my document.txt")
for f in "${files[@]}"; do ...  # Iterates correctly
```

**Self-challenge**: If you're using unquoted expansion, ask: "Do I want word splitting and glob expansion here?" 99% of the time, the answer is no.
