# Code Review Checklist

## Overview

Every bash script change must pass this review. Use this checklist before merging.

**Confidence**: Synthesized from all skill guides, Google Shell Style Guide principles, and OWASP security guidance. Verified against multiple authoritative sources just now.

## 🚨 Critical Security

- [ ] **No `eval`** on untrusted input or user-controlled data
- [ ] **All variables quoted** — no unquoted `$var` unless word splitting is explicitly intended
- [ ] **`--` separator** used before positional arguments in commands that accept flags
- [ ] **No predictable temp paths** like `/tmp/script.tmp` — always use `mktemp`
- [ ] **No `sudo` added** to commands that don't genuinely need root
- [ ] **No `sudo` removed** from commands that genuinely need root
- [ ] **No path traversal** — user-supplied paths validated against allowlist or canonicalized
- [ ] **No dangerous naming** — no digit-starting variable names, no hyphens in names, no bare `_` variable
- [ ] **No empty functions** — use `:` null command if placeholder needed
- [ ] **`<` in `[ ]`** — never does numeric comparison; use `-lt` or `[[ ]]` instead

## ⚠️ Error Handling and Robustness

- [ ] **`set -euo pipefail`** at the top of every script
- [ ] **`trap` cleanup** for temp files and resources
- [ ] **`cd` failures handled** — `cd /path || exit 1` or wrapped in subshell
- [ ] **Downloads wrapped** in `if wget/curl ...; then ... fi` with graceful fallback
- [ ] **`gum confirm` in conditionals** — never standalone (would abort under `set -e` on "No")
- [ ] **`command -v` checks** for required dependencies before use
- [ ] **Argument validation** — count, format, and allowlist checks

## 📐 Style and Maintainability

- [ ] **Syntax check passes** — `bash -n script.sh`
- [ ] **ShellCheck passes** — or each warning is understood and justified
- [ ] **No `function` keyword** — POSIX `func_name() { }` style
- [ ] **`local` variables** in all functions
- [ ] **`then` on same line** as `if`, `do` on same line as `while`
- [ ] **2-space indentation** — no tabs
- [ ] **Line length ≤ 80 chars** (where practical)
- [ ] **Comments are lowercase** with no trailing punctuation (unless meaning requires it)
- [ ] **Verb-prefixed file names** — `provision-*.sh`, `configure-*.sh`, `revert-*.sh`
- [ ] **kebab-case.sh** for script file names

## 🔄 Reversibility

- [ ] **Every newly provisioned component** has a corresponding revert script
- [ ] **Revert scripts are tested** or at minimum reviewed for correctness
- [ ] **No orphaned state** left behind if script is interrupted

## 📚 Documentation

- [ ] **Script header** present — shebang, description, usage
- [ ] **Non-obvious decisions** explained in comments
- [ ] **README updated** if user-facing behavior changed
- [ ] **AGENTS.md updated** if architecture or standards changed

## 🧪 Testing

- [ ] **Run twice** — second run is safe (idempotency)
- [ ] **Error paths tested** — what happens when download fails?
- [ ] **Spaces in paths** — tested with filenames containing spaces
- [ ] **Ctrl+C cleanup** — temp files removed on interrupt

## 🚫 Forbidden References

- [ ] **No references** to forbidden project names anywhere in code or docs

**Self-challenge**: If this script failed at the worst possible moment, what state would the system be left in? Could it be worse than if the script had never run?
