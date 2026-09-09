# Agents Guide

This file is the single source of truth for any person, AI, or agent working on this project. Read it fully before touching any code. It covers design philosophy, architecture, code style, review constraints, verification discipline, and the why behind every non-obvious decision.

If you are an AI agent, read the whole file. Do not skim.

## What This Project Is

JustBuntu is a one-command setup script for Ubuntu desktop. It is opinionated where opinions reduce friction, and restrained where opinions would impose themselves. The result is a system that arrives configured but not constrained. While crafted with developers as the primary audience, it avoids narrow specialization and remains approachable for anyone who wants a clean, capable desktop. "Done right" means the script runs unattended after the initial choices, produces a system that behaves predictably, and stays out of the user's way — no themes, no distractions, no aesthetic layer demanding attention. It targets Ubuntu desktop with GNOME when available, but degrades gracefully to terminal-only tools on systems without GNOME.

## Design Philosophy

### Unobtrusive by Design

The project installs tools and configures only what is necessary for a solid baseline. Shell customization is kept to the absolute minimum required for the project's own commands to work. The user gets a system that feels like stock Ubuntu, refined rather than replaced. This principle was chosen over a heavily customized experience because the target audience wants a desktop that recedes, not one that announces itself.

### Explicit and Reversible

Every change the installer makes should be understandable by reading the corresponding script file. Optional components are gated behind explicit user choice, not silently included. Anything installed gets a corresponding uninstall path. This was chosen over opaque "magic" setup because users need to trust and understand what runs on their system.

### Focused Extension Set

On GNOME, a focused set of third-party shell extensions is installed. Default Ubuntu extensions may be disabled or configured. The shell stays close to stock behavior while fixing real annoyances.

### Inclusive Defaults

The baseline configuration serves developers first, but the system remains approachable and useful for non-developers. Opinions are held lightly; utility is held strongly.

## Architecture

The repository is divided into stable functional domains: `core/` contains
orchestration, `lib/` contains shared infrastructure, `provision/` contains
installation and configuration modules, and `revert/` contains cleanup paths.
`install.sh` wires these modules together and should not contain component
installation logic. The repository itself is the source of truth for the
current file inventory; this guide intentionally does not duplicate it.

Guidance files describe durable contracts, not current inventories, versions,
provider URLs, or one-off fixes. Update them when a durable rule changes, not
after every implementation edit. Revert scripts may remove provisioned
components and reset their settings, but must not remove the core needed to
run JustBuntu again.

### Execution and Module Boundaries

The installer runs as a series of sourced Bash modules. Each module is
responsible for one component, while `install.sh` wires modules together and
does not contain component installation logic. No script may assume a specific
working directory; resolve paths from `$JUSTBUNTU_PATH`, `$HOME`, or the
sourced file's own location.

## Code Style

### Comments

Write like a lazy senior engineer jotting quick notes. Sentence case for the first word. Proper nouns and acronyms capitalized (Ubuntu, GNOME, CLI, Super, Alt, Homebrew, JetBrains). Light punctuation — periods at the end of complete thoughts, commas where they help. Don't force perfect grammar. Don't overdo it.

Explain why, not what the code already shows.

No block comment boxes. No doc-comment banners like JSDoc or Doxygen. Use the language's plain single-line comment syntax only.

No references to other projects by name in comments.

No LLM-smell phrases like "here we," "let's," "we need to," "note that," "important," "todo," "fixme."

For obscure or uncommon code, provide both what and why. For common code, provide only why.

Provide verified working links whenever possible. Prefer primary or official documentation over blog posts.

Maximum three consecutive comment lines without intervening code. The fourth line must be code, or the structure must be refactored to interleave comments and code. Comments are annotations, not paragraphs.

### Code Structure

Split logic into many small files each with a single responsibility.

Keep the entry point as small as possible. It should only wire things together.

Keep setup and teardown logic next to each other for easy review.

One concept per file, one file per concept.

Prefer pure functions with no side effects in utility files.

Every resource acquired during setup is released during teardown. If you add a new resource, you must add its cleanup in the corresponding teardown path.

This project is written in bash only. No TypeScript, no build step, no compilation. All scripts must run with `set -e` and must be idempotent where practical.

### Anti AI-Code Smells

Do not wrap standard API calls in try/catch blocks.

Do not use try/catch to silence errors that should never happen. Return null instead.

Try/catch is legitimate only for genuine external failure points:
- File I/O. Reading or writing to disk. Files can be deleted, corrupt, or permission denied.
- Parsing data that originated outside the code.
- Reading data owned by another process or application.
- Configuration or settings values that users could manually edit.

When catching, always explain why the operation can genuinely fail.

For bundled or packaged resource failures, surface the error through the project's normal logging or error-reporting path so it is not silently swallowed.

Do not use optional chaining `?.` or nullish coalescing `??` or your language's equivalent for values guaranteed to exist.

Do not add defensive null checks that mask bugs instead of handling them.

Do not add "just in case" code for situations that cannot occur.

Do not add comments that describe what a line does. Only describe why.

Do not add `sudo` to commands that do not require it, and do not remove `sudo` from commands that genuinely need it.

### Review Discipline

Before producing final output, read every single line you wrote.

Look for potential issues on every line, not just the line you are currently editing.

When fixing a bug, check whether the same bug pattern exists elsewhere in the codebase.

Do not assume a fix works. Verify it against the actual code.

## Verification Discipline

Treat every factual claim as a hypothesis until you have stated your actual basis for it. Before answering, ask yourself: "Am I recalling this from training data, or did I just verify it?" If it is the former, say so.

Tag factual claims (dates, statistics, current events, technical specs, prices, laws, who holds what position, version numbers) with their basis. Do not blend them silently into one confident paragraph. Use something close to "Verified via [tool or source] just now" / "From training data (may be outdated or wrong)" / "Not verified — please confirm independently."

If tools are available, use them for anything time-sensitive, numeric, or checkable. A completed search is not the same as a correct citation. After retrieving a source, re-read it and confirm the summary actually matches before presenting it as confirmed. Give the real URL retrieved, not a plausible-looking one. If a live source cannot be reached right now, say so explicitly rather than presenting an unverified claim as fact.

If tools are not available, never claim to have searched, checked, or verified something. Never invent a citation, link, or source name to sound credible. Say plainly: "This cannot be verified. It is from training data and could be stale or wrong."

Before finalizing a nontrivial claim, ask: "What would prove this wrong? Is there a more recent or more authoritative source that could contradict this?" If there is a plausible way you are wrong, say so instead of smoothing over it.

A broken or made-up-looking URL is worse than no URL. If there is no real, verified link, do not give one. Say there is not one.

Distinguish widely believed from confirmed. Popular belief and common knowledge are not the same as verified fact. Flag when repeating a common claim that has not been personally checked.

When corrected, re-check. Do not immediately flip to agreeing, and do not reflexively defend the original claim either. Re-examine the actual basis for both claims, then say honestly which one holds up, or if you genuinely do not know.

## Testing

### Static Analysis

Run `bash -n` on every modified `.sh` file to check for syntax errors.

### Build and Syntax Check

```bash
find . -name "*.sh" -exec bash -n {} \;
```

This command must exit cleanly with no output before any change is considered done.

### Manual Testing

Test changes with the smallest relevant checks first. For desktop-path
changes, cover both GNOME and non-GNOME behavior when practical. A full clean
VM or container run is a release-level check for installer-flow changes, not a
requirement for every local edit.
