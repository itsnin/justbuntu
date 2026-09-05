# Agents Guide

This file is the single source of truth for any person, AI, or agent working on this project. Read it fully before touching any code. It covers design philosophy, architecture, code style, review constraints, verification discipline, and the why behind every non-obvious decision.

If you are an AI agent, read the whole file. Do not skim.

## What This Project Is

JustBuntu is a one-command setup script that turns a fresh Ubuntu 26.04 LTS or newer installation into what Ubuntu should have been all along. It is opinionated where opinions reduce friction, and restrained where opinions would impose themselves. The result is a system that arrives configured but not constrained. While crafted with developers as the primary audience, it avoids narrow specialization and remains approachable for anyone who wants a clean, capable desktop. "Done right" means the script runs unattended after the initial choices, produces a system that behaves predictably, and stays out of the user's way — no themes, no distractions, no aesthetic layer demanding attention. It targets Ubuntu desktop with GNOME when available, but degrades gracefully to terminal-only tools on systems without GNOME.

## Design Philosophy

### Unobtrusive by Design

The project installs tools and configures only what is necessary for a solid baseline. Shell customization is kept to the absolute minimum required for the project's own commands to work. The user gets a system that feels like stock Ubuntu, refined rather than replaced. This principle was chosen over a heavily customized experience because the target audience wants a desktop that recedes, not one that announces itself.

### Explicit and Reversible

Every change the installer makes should be understandable by reading the corresponding script file. Optional components are gated behind explicit user choice, not silently included. Anything installed gets a corresponding uninstall path. This was chosen over opaque "magic" setup because users need to trust and understand what runs on their system.

### Focused Extension Set

On GNOME, a focused set of third-party shell extensions is installed: Spotlight, Space Bar, Just Perfection, GSConnect, Caffeine, Copyous, and Emoji Copy. Default Ubuntu extensions may be disabled or configured. This set is chosen to add meaningful capability without heavy customization. Each extension has a clear purpose and is actively maintained. The shell stays close to stock behavior while fixing real annoyances.

### Inclusive Defaults

The baseline configuration serves developers first, but the system remains approachable and useful for non-developers. Opinions are held lightly; utility is held strongly.

## Architecture

### File Layout

The project is organized into distinct functional domains, each with a clear responsibility. Directory and file names communicate intent precisely.

```
justbuntu/
    bootstrap.sh                 Entry point. Clones repository and initiates provisioning
    provision/orchestrate.sh     Primary orchestrator. Wires together core validation,
                                 preference gathering, logging, error recovery, and domain-specific provisioners
    banner.sh                    ASCII art banner displayed at startup
    version                      Plain text version number, calendar-based
    bin/
        justbuntu                CLI entry point for post-install management
        commands/                Individual menu actions: install, update, revert, etc.
    config/                     Static configuration files (bashrc)
    share/                      Shared assets: .desktop entry generators and icons
        icons/                  PNG icons referenced by desktop entries
    shell/                      Shell environment: PATH, aliases, functions, prompt
        bash/
    provision/
        orchestrate-terminal.sh  Runs all terminal provisioning modules
        orchestrate-desktop.sh   Runs all desktop provisioning modules (GNOME only)
        helpers/                   Install logging to /var/log/justbuntu-install.log and
                                   sophisticated error handling with retry menu
            logging.sh                  Tee-based log redirection, run_script helper with CURRENT_SCRIPT tracking, start/stop timing
            errors.sh                   ERR trap, retry menu, log viewer, graceful recovery
        core/                    Foundational setup: system validation, snapd, kdump, preferences
            validate-system.sh        OS and architecture validation
            configure-snapd.sh         Snapd retention or removal choice
            purge-kdump.sh             Kdump-tools removal to free reserved memory
            gather-preferences.sh      ALL interactive choices upfront: snapd, dev languages, browsers, optional apps, web apps, AI assistants, GNOME extensions
        terminal/                Terminal environment provisioning
            prerequisites/            Dependencies required before interactive prompts
                provision-gum.sh      Gum TUI library installation
                provision-homebrew.sh   Homebrew package manager for Linux (mandatory)
            configure-git.sh          Git identity and behavior
            configure-shell-profile.sh Shell profile deployment
            provision-cli-utilities.sh Fastfetch, btop, wget, curl, micro
            provision-dev-tooling.sh   Selectable language and tool installation
            provision-github-cli.sh    GitHub CLI via apt repo
            provision-system-libraries.sh Common development libraries
        desktop/                 Desktop environment provisioning
            configure-app-grid.sh          Application folder organization
            configure-browsers.sh          Browser selection and installation
            configure-default-terminal.sh  Ghostty as default terminal emulator
            configure-desktop-preferences.sh Window behavior, calendar, ambient sensors
            configure-dock.sh              Dash favorite-apps configuration
            configure-keybindings.sh       Keyboard shortcuts: Super+w close, Super+Up maximize, Super+e files, 9 fixed workspaces, Alt+1-9 apps, Super+1-9 workspaces
            configure-shell-extensions.sh  Install 7 extensions, disable 6 Ubuntu extensions, copy schemas + compile, set prefs, resolve Super+V and Super+. keybinding conflicts
            extensions/                     User-choice desktop applications
                provision-jetbrains-toolbox.sh
                provision-obs-studio.sh
                provision-spotify.sh
                provision-slack.sh
                provision-discord.sh
                provision-web-apps.sh
            provision-extensions.sh        Extension selection orchestrator
            provision-ai-assistants.sh     AI tools orchestrator (Claude Desktop + 4 CLI tools)
            ai/                           AI assistant installers
                provision-claude-desktop.sh
            provision-ghostty.sh            GPU-accelerated terminal emulator
            provision-gnome-boxes.sh        Virtual machine manager
            provision-gnome-sushi.sh        File preview capability
            provision-gnome-tweaks.sh       Desktop customization interface
            provision-localsend.sh          Cross-platform file transfer
            provision-obsidian.sh           Knowledge base application
            provision-vlc.sh                Media player
            provision-vscode.sh             Code editor
            register-desktop-entries.sh     Desktop entry registration
    revert/                      Revert scripts for every provisioned component.
                                 Important: revert scripts never touch JustBuntu core files.
                                 The CLI, desktop icon, shell config, and ~/.local/share/justbuntu/
                                 are permanent once installed. Users can re-provision at any time.
                                 revert-all-components.sh runs all revert scripts (full reset option).
                                 Uninstall menu offers: reset all components, or select individual items.
    skills/                      Skill definitions for AI agents and code standards
        scripting-style-guide/        Naming, formatting, aesthetics, structure
        strict-mode-error-handling/   set -euo pipefail, trap, error patterns
        defensive-programming/        Input validation, dry-run, idempotency, mktemp
        security-anti-patterns/       Eval avoidance, command injection, quoting
        variables-and-quoting/        Variable scope, expansion, quoting rules
        functions-and-modularity/     Function design, return codes, sourcing
        conditionals-control-flow/    [[ vs [, case, loops, subshell pitfalls
        arrays-argument-parsing/      Array usage, getopts, safe argument passing
        portability-compatibility/    Shebang choices, POSIX vs bash, macOS vs Linux
        logging-observability/        Log levels, structured logging, verbosity
        testing-and-linting/          ShellCheck, bats, syntax check, CI
        filesystem-operations/        Mktemp, atomic writes, locking, glob safety
        process-management/           Background jobs, signals, trap, wait
        command-execution-patterns/   Command substitution, pipes, xargs, cd safety
        code-review-checklist/        Mandatory review checklist for all changes
```

### Execution and Module Boundaries

The installer runs as a series of sourced bash scripts. Each script file is responsible for one component and one component only. The primary `provision/orchestrate.sh` wires things together and should never contain direct installation logic itself. `orchestrate-terminal.sh` and `orchestrate-desktop.sh` use glob loops over their respective directories, so adding a new component is as simple as dropping a new `.sh` file in the right place. No script may assume it is being run from a specific working directory — always use absolute paths rooted at `$JUSTBUNTU_PATH` or `$HOME`.

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

Target environment: Ubuntu 26.04 LTS desktop, x86_64, with GNOME. The project should also be tested on a system without GNOME to verify the graceful degradation path. At minimum, run the bootstrap script in a clean VM or container and confirm: the version check passes, interactive prompts appear, terminal tools install without error, and the `justbuntu` command is available in PATH after installation.
