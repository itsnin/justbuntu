# Security Anti-Patterns

## Overview

Recognize and eliminate the most dangerous security vulnerabilities in shell scripts.

**Confidence**: Verified via OWASP Command Injection guide, commandinline.com, linuxbash.sh, Kinda Technical just now.

## Critical: Never Use `eval` on Untrusted Input

`eval` executes arbitrary strings as shell code. Any user-controlled data passed to `eval` becomes **remote code execution**.

```bash
# DANGEROUS — remote code execution vulnerability
user_input="$1"
eval "echo $user_input"
# If $1 = "hello; rm -rf /", this deletes files

# DANGEROUS — building commands as strings
cmd="grep $pattern access.log"
eval "$cmd"
```

**Safe alternatives**:
- Use arrays to build commands
- Use parameter expansion
- Use functions instead of dynamic code

## Command Injection via Unquoted Variables

Unquoted variables undergo word splitting and glob expansion. An attacker can inject flags or commands.

```bash
# VULNERABLE
grep $user_pattern /etc/passwd
# If $user_pattern = "-e /etc/shadow", grep reads /etc/shadow

# SAFE — always quote variables
grep -- "$user_pattern" /etc/passwd
```

## The `--` Separator

Use `--` to signal end of options. Anything after `--` is treated as a positional argument, even if it starts with `-`.

```bash
# Without --, user input starting with - is parsed as flags
rm "$filename"          # DANGEROUS if $filename = "-rf /"

# With --, filenames starting with - are safe
rm -- "$filename"        # SAFE
```

## Dangerous Commands to Avoid

| Anti-Pattern | Risk | Safe Alternative |
|-------------|------|-----------------|
| `eval` | Arbitrary code execution | Arrays, functions |
| `source` on untrusted file | Code execution | Parse with `grep`/`awk` |
| Unquoted `$*` | Word splitting | `"$@"` for argument passing |
| `echo` with untrusted data | Flag injection (`-e`, `-n`) | `printf '%s\n' "$data"` |
| Backticks `` `cmd` `` | Nesting confusion | `$(cmd)` |
| `>` on user-controlled path | Arbitrary file overwrite | Validate path first |

## Path Traversal

```bash
# VULNERABLE
cat "/var/data/$user_input"
# If $user_input = "../../etc/passwd", reads /etc/passwd

# SAFE — validate or canonicalize
real_path=$(realpath -m "/var/data/$user_input")
[[ "$real_path" == /var/data/* ]] || { echo "invalid path" >&2; exit 1; }
```

## Running as Root

- Drop privileges when possible
- Use `sudo` only for commands that genuinely need it
- Never add `sudo` to commands that don't require it
- Never remove `sudo` from commands that genuinely need it

## Environment Variable Trust

Environment variables can be manipulated by the caller. Treat them as untrusted input:

```bash
# Validate before trusting
: "${EDITOR:=nano}"
case "$EDITOR" in
    nano|vim|vi|emacs) ;;
    *) echo "error: untrusted editor: $EDITOR" >&2; exit 1 ;;
esac
```

## Naming Anti-Patterns

**Verified via ABS Guide Chapter 34 just now**.

| Anti-Pattern | Risk | Fix |
|-------------|------|-----|
| Digit-starting names | `23skidoo=value` — reserved by shell | Use `_23skidoo` or descriptive name |
| `_` alone as variable | `$_` is special — holds last arg of last command | Never use bare `_` as variable name |
| Hyphens in names | `var-1=23` or `func-name()` — syntax error | Use underscores: `var_1`, `func_name` |
| Periods in function names | Not allowed in bash 3+ | Use underscores or mixed case |
| Same name for var and function | Severe confusion and bugs | Use distinct namespaces |

## Comparison Operator Pitfalls

```bash
# DANGEROUS — < in [ ] does ASCII comparison, NOT numeric
if [ "$greater" \< "$lesser" ]; then  # "105" < "5" is TRUE in ASCII!

# SAFE — use numeric comparison operators
if [[ "$greater" -lt "$lesser" ]]; then
```

## `let` on Strings

```bash
# SILENT FAILURE — let on non-numeric strings gives 0
let "a = hello, you"
echo "$a"  # outputs 0, no error!

# SAFE — never use let for string assignment
a="hello, you"
```

 If yes, the script has a security vulnerability.
