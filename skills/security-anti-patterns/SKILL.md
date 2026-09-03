# Security Anti-Patterns

## Never Use `eval` on Untrusted Input

`eval` executes arbitrary strings as shell code. Any user-controlled data passed to `eval` becomes remote code execution.

Safe alternatives: arrays to build commands, parameter expansion, functions instead of dynamic code.

## Command Injection via Unquoted Variables

Unquoted variables undergo word splitting and glob expansion. Always quote variables.

## The `--` Separator

Use `--` to signal end of options. Anything after `--` is treated as a positional argument, even if it starts with `-`.

```bash
rm -- "$filename"        # SAFE even if $filename starts with -
```

## Dangerous Commands to Avoid

| Anti-Pattern | Safe Alternative |
|-------------|-----------------|
| `eval` | Arrays, functions |
| `source` on untrusted file | Parse with `grep`/`awk` |
| Unquoted `$*` | `"$@"` for argument passing |
| `echo` with untrusted data | `printf '%s\n' "$data"` |
| Backticks `` `cmd` `` | `$(cmd)` |

## Path Traversal

```bash
real_path=$(realpath -m "/var/data/$user_input")
[[ "$real_path" == /var/data/* ]] || { echo "invalid path" >&2; exit 1; }
```

## Running as Root

- Drop privileges when possible
- Use `sudo` only for commands that genuinely need it
- Never add `sudo` to commands that don't require it
- Never remove `sudo` from commands that genuinely need it

## Environment Variable Trust

Environment variables can be manipulated by the caller. Treat them as untrusted input and validate before trusting.

## Naming Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| Digit-starting names | Use descriptive name or `_` prefix |
| `_` alone as variable | Never use bare `_` as variable name |
| Hyphens in names | Use underscores |
| Same name for var and function | Use distinct namespaces |

## Comparison Operator Pitfalls

```bash
# DANGEROUS — < in [ ] does ASCII comparison, NOT numeric
if [[ "$greater" -lt "$lesser" ]]; then    # RIGHT — numeric comparison
```

## `let` on Strings

`let "a = hello"` silently gives 0 with no error. Never use `let` for string assignment. Use direct assignment: `a="hello"`.
