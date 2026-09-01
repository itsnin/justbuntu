# agents guide

this file is the single source of truth for any person ai or agent working on this project read it fully before touching any code it covers design philosophy architecture code style review constraints verification discipline and the why behind every non-obvious decision

if you are an ai agent read the whole file do not skim

## what this project is

justbuntu is a one-command setup script that turns a fresh ubuntu 26.04 lts or newer installation into what ubuntu should have been all along. it is opinionated where opinions reduce friction, and restrained where opinions would impose themselves. the result is a system that arrives configured but not constrained. while crafted with developers as the primary audience, it avoids narrow specialization and remains approachable for anyone who wants a clean, capable desktop. "done right" means the script runs unattended after the initial choices, produces a system that behaves predictably, and stays out of the user's way — no themes, no distractions, no aesthetic layer demanding attention. it targets ubuntu desktop with gnome when available, but degrades gracefully to terminal-only tools on systems without gnome.

## design philosophy

### unobtrusive by design

the project installs tools and configures only what is necessary for a solid baseline. shell customization is kept to the absolute minimum required for the project's own commands to work. the user gets a system that feels like stock ubuntu, refined rather than replaced. this principle was chosen over a heavily customized experience because the target audience wants a desktop that recedes, not one that announces itself.

### explicit and reversible

every change the installer makes should be understandable by reading the corresponding script file. optional components are gated behind explicit user choice, not silently included. anything installed gets a corresponding uninstall path. this was chosen over opaque "magic" setup because users need to trust and understand what runs on their system.

### one extension only

on gnome, exactly one third-party shell extension is installed: spotlight. default ubuntu extensions may be disabled or configured, but no additional third-party extensions are added. this keeps the shell close to stock behavior and reduces maintenance surface.

### inclusive defaults

the baseline configuration serves developers first, but the system remains approachable and useful for non-developers. opinions are held lightly; utility is held strongly.

## architecture

### file layout

the project is organized into distinct functional domains, each with a clear responsibility. directory and file names communicate intent precisely:

```
justbuntu/
    bootstrap.sh                 entry point. clones repository and initiates provisioning
    provision/orchestrate.sh     primary orchestrator. wires together core validation,
                                 preference gathering, logging, error recovery, and domain-specific provisioners
    banner.sh                    ascii art banner displayed at startup
    version                      plain text version number, calendar-based
    bin/
        justbuntu                cli entry point for post-install management
        commands/                individual menu actions: install, update, revert, etc.
    config/                     static configuration files (bashrc)
    share/                      shared assets: .desktop entry generators and icons
        icons/                  png icons referenced by desktop entries
    shell/                      shell environment: path, aliases, functions, prompt
        bash/
    provision/
        orchestrate-terminal.sh  runs all terminal provisioning modules
        orchestrate-desktop.sh   runs all desktop provisioning modules (gnome only)
        helpers/                   install logging to /var/log/justbuntu-install.log and
                                   sophisticated error handling with retry menu
            logging.sh                  tee-based log redirection, run_script helper with CURRENT_SCRIPT tracking, start/stop timing
            errors.sh                   ERR trap, retry menu, log viewer, graceful recovery
        core/                    foundational setup: system validation, snapd, kdump, preferences
            validate-system.sh        os and architecture validation
            configure-snapd.sh         snapd retention or removal choice
            purge-kdump.sh             kdump-tools removal to free reserved memory
            gather-preferences.sh      ALL interactive choices upfront: snapd, dev languages, browsers, optional apps, web apps, AI assistants, gnome extensions
        terminal/                terminal environment provisioning
            prerequisites/            dependencies required before interactive prompts
                provision-gum.sh      gum tui library installation
            configure-git.sh          git identity and behavior
            configure-shell-profile.sh shell profile deployment
            provision-cli-utilities.sh fastfetch, btop, wget, curl, micro
            provision-dev-tooling.sh   selectable language and tool installation
            provision-github-cli.sh    github command-line interface
            provision-system-libraries.sh common development libraries
        desktop/                 desktop environment provisioning
            configure-app-grid.sh          application folder organization
            configure-browsers.sh          browser selection and installation
            configure-default-terminal.sh  ghostty as default terminal emulator
            configure-desktop-preferences.sh window behavior, calendar, ambient sensors
            configure-dock.sh              dash favorite-apps configuration
            configure-keybindings.sh       keyboard shortcuts: Super+w close, Super+Up maximize, Super+e files, 9 fixed workspaces, Alt+1-9 apps, Super+1-9 workspaces
            configure-shell-extensions.sh  install 5 extensions, disable 6 ubuntu extensions, copy schemas + compile, set Space Bar + Just Perfection prefs
            extensions/                     user-choice desktop applications
                provision-jetbrains-toolbox.sh
                provision-obs-studio.sh
                provision-spotify.sh
                provision-slack.sh
                provision-discord.sh
                provision-web-apps.sh
            provision-extensions.sh        extension selection orchestrator
            provision-ai-assistants.sh     ai assistant selection orchestrator
            ai/                           ai assistant installers
                provision-claude-desktop.sh
            provision-ghostty.sh            gpu-accelerated terminal emulator
            provision-gnome-boxes.sh        virtual machine manager
            provision-gnome-sushi.sh        file preview capability
            provision-gnome-tweaks.sh       desktop customization interface
            provision-localsend.sh          cross-platform file transfer
            provision-obsidian.sh           knowledge base application
            provision-vlc.sh                media player
            provision-vscode.sh             code editor
            register-desktop-entries.sh     desktop entry registration
    revert/                      revert scripts for every provisioned component.
                                 important: revert scripts never touch justbuntu core files.
                                 the cli, desktop icon, shell config, and ~/.local/share/justbuntu/
                                 are permanent once installed. users can re-provision at any time.
                                 revert-all-components.sh runs all revert scripts (full reset option).
                                 uninstall menu offers: reset all components, or select individual items.
    skills/                      skill definitions for ai agents and code standards
        scripting-style-guide/        naming, formatting, aesthetics, structure
        strict-mode-error-handling/   set -euo pipefail, trap, error patterns
        defensive-programming/        input validation, dry-run, idempotency, mktemp
        security-anti-patterns/       eval avoidance, command injection, quoting
        variables-and-quoting/        variable scope, expansion, quoting rules
        functions-and-modularity/     function design, return codes, sourcing
        conditionals-control-flow/    [[ vs [, case, loops, subshell pitfalls
        arrays-argument-parsing/      array usage, getopts, safe argument passing
        portability-compatibility/    shebang choices, POSIX vs bash, macOS vs Linux
        logging-observability/        log levels, structured logging, verbosity
        testing-and-linting/          shellcheck, bats, syntax check, CI
        filesystem-operations/        mktemp, atomic writes, locking, glob safety
        process-management/           background jobs, signals, trap, wait
        command-execution-patterns/   command substitution, pipes, xargs, cd safety
        code-review-checklist/        mandatory review checklist for all changes
```

### execution and module boundaries

the installer runs as a series of sourced bash scripts. each script file is responsible for one component and one component only. the primary `provision/orchestrate.sh` wires things together and should never contain direct installation logic itself. `orchestrate-terminal.sh` and `orchestrate-desktop.sh` use glob loops over their respective directories, so adding a new component is as simple as dropping a new `.sh` file in the right place. no script may assume it is being run from a specific working directory — always use absolute paths rooted at `$JUSTBUNTU_PATH` or `$HOME`.

## code style

### comments

- all comments are lowercase no exceptions unless a capital letter is required to preserve meaning for example `curl -fsSL` must keep the capital `S` and `L` because they are case-sensitive flags
- no punctuation in comments no periods no commas no exclamation marks no question marks unless punctuation changes meaning
- explain why not what the code already shows what it does
- no block comment boxes no doc-comment banners like jsdoc or doxygen use the language's plain single-line comment syntax only
- no references to other projects by name in comments
- no llm-smell phrases like "here we" "let's" "we need to" "note that" "important:" "todo" "fixme"
- for obscure or uncommon code provide both what and why for common code provide only why
- provide verified working links whenever possible prefer primary or official documentation over blog posts
- maximum three consecutive comment lines without intervening code the fourth line must be code or the structure must be refactored to interleave comments and code comments are annotations not paragraphs

### code structure

- split logic into many small files each with a single responsibility
- keep the entry point as small as possible it should only wire things together
- keep setup and teardown logic next to each other for easy review
- one concept per file one file per concept
- prefer pure functions with no side effects in utility files
- every resource acquired during setup is released during teardown if you add a new resource you must add its cleanup in the corresponding teardown path
- this project is written in bash only no typescript no build step no compilation. all scripts must run with `set -e` and must be idempotent where practical

### anti ai-code smells

- do not wrap standard api calls in try/catch blocks
- do not use try/catch to silence errors that should never happen return null instead
- try/catch is legitimate only for genuine external failure points:
  - file io reading writing to disk files can be deleted corrupt or permission denied
  - parsing data that originated outside the code
  - reading data owned by another process or application
  - configuration or settings values that users could manually edit
- when catching always explain why the operation can genuinely fail
- for bundled or packaged resource failures surface the error through the project's normal logging or error-reporting path so it is not silently swallowed
- do not use optional chaining `?.` or nullish coalescing `??` or your language's equivalent for values guaranteed to exist
- do not add defensive null checks that mask bugs instead of handling them
- do not add "just in case" code for situations that cannot occur
- do not add comments that describe what a line does only describe why
- do not add `sudo` to commands that do not require it and do not remove `sudo` from commands that genuinely need it

### review discipline

- before producing final output read every single line you wrote
- look for potential issues on every line not just the line you are currently editing
- when fixing a bug check whether the same bug pattern exists elsewhere in the codebase
- do not assume a fix works verify it against the actual code

## verification discipline

- treat every factual claim as a hypothesis until you have stated your actual basis for it before answering ask yourself am i recalling this from training data or did i just verify it if it is the former say so
- tag factual claims dates statistics current events technical specs prices laws who holds what position version numbers with their basis do not blend them silently into one confident paragraph use something close to verified via [tool or source] just now / from training data may be outdated or wrong / not verified confirm independently
- if tools are available use them for anything time sensitive numeric or checkable a completed search is not the same as a correct citation after retrieving a source re-read it and confirm the summary actually matches before presenting it as confirmed give the real url retrieved not a plausible looking one if a live source cannot be reached say so explicitly rather than presenting an unverified claim as fact
- if tools are not available never claim to have searched checked or verified something never invent a citation link or source name to sound credible say plainly this cannot be verified it is from training data and could be stale or wrong
- before finalizing a nontrivial claim ask what would prove this wrong is there a more recent or more authoritative source that could contradict it if there is a plausible way the claim is wrong say so instead of smoothing over it
- a broken or made up looking url is worse than no url if there is no real verified link do not give one say there is not one
- distinguish widely believed from confirmed popular belief and common knowledge are not the same as verified fact flag when repeating a common claim that has not been personally checked
- when corrected re-check do not immediately flip to agreeing and do not reflexively defend the original claim either re-examine the actual basis for both claims then say honestly which one holds up or if it is genuinely unclear

## testing

### static analysis

run `bash -n` on every modified `.sh` file to check for syntax errors.

### build and syntax check

```bash
find . -name "*.sh" -exec bash -n {} \;
```

this command must exit cleanly with no output before any change is considered done.

### manual testing

target environment: ubuntu 26.04 lts desktop x86_64 with gnome. the project should also be tested on a system without gnome to verify the graceful degradation path. at minimum, run the bootstrap script in a clean vm or container and confirm: the version check passes, interactive prompts appear, terminal tools install without error, and the `justbuntu` command is available in path after installation.
