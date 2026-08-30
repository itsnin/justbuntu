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

**Self-challenge**: Is there any path from user input to shell metacharacter interpretation? If yes, the script has a security vulnerability.
