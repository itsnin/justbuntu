# agents guide

this file is the single source of truth for any person ai or agent working on this project read it fully before touching any code it covers design philosophy architecture code style review constraints verification discipline and the why behind every non-obvious decision

if you are an ai agent read the whole file do not skim

## what this project is

justbuntu is a one-command setup script that turns a fresh ubuntu 26.04 lts or newer installation into a configured web development system. it is for developers who want a reproducible, opinionated starting point without spending hours on manual configuration. "done right" means the script runs unattended after the initial choices, produces a system that behaves predictably, and stays out of the user's way — no excessive customization, no theme switching, no surprising shell behavior. it targets ubuntu desktop with gnome when available, but degrades gracefully to terminal-only tools on systems without gnome.

## design philosophy

### minimal not decorated

the project installs tools and configures only what is necessary for a solid development baseline. shell customization is kept to the absolute minimum required for the project's own commands to work. the user gets a system that feels like ubuntu, not a themed fork. this principle was chosen over a heavily customized experience because the target audience is developers who want to add their own preferences on top of a stable base, not inherit someone else's aesthetic.

### explicit and reversible

every change the installer makes should be understandable by reading the corresponding script file. optional components are gated behind explicit user choice, not silently included. anything installed gets a corresponding uninstall path. this was chosen over opaque "magic" setup because developers need to trust and understand what runs on their system.

### no forbidden references

the project must never reference the original upstream project or its creators by name anywhere in code, comments, docs, or commit messages. this is a hard boundary with no exceptions. describe generically if a comparison is genuinely needed, or omit the reference entirely.

### one extension only

on gnome, exactly one third-party shell extension is installed: spotlight. default ubuntu extensions may be disabled or configured, but no additional third-party extensions are added. this keeps the shell close to stock behavior and reduces maintenance surface.

## architecture

### file layout

```
justbuntu/
    bootstrap.sh                 curl entry point, clones repo and starts install
    install.sh                   main orchestrator, sources version check and sub-installers
    banner.sh                    ascii art banner displayed at start
    version                      plain text version number
    bin/
        justbuntu                cli entry point for post-install management
        subcommands/             individual menu actions (install, update, uninstall, etc.)
    app-launchers/               desktop entry files for docker, justbuntu, whatsapp
        icons/                   png icons for the above launchers
    configs/
        bashrc                   minimal bashrc that sources the shell defaults
    install/
        check-version.sh         os and architecture validation
        first-run-choices.sh     interactive prompts for language and database selection
        terminal.sh              runs all terminal/*.sh installers
        desktop.sh               runs all desktop/*.sh installers (gnome only)
        terminal/                core terminal tools: docker, git, fastfetch, etc.
            required/            prerequisites needed before interactive prompts
            select-dev-language.sh   selectable language installation (python, rust, node, etc.)
            select-dev-storage.sh    selectable database installation via docker
        desktop/                 core desktop apps: chrome, vscode, ghostty, etc.
            optional/             user-choice apps: jetbrains toolbox, obs studio, spotify, web apps
    shell-defaults/bash/         minimal shell configuration: path, aliases, functions, prompt
    uninstall/                   uninstall scripts for every component that can be installed
    skills/                      skill files for ai agents working on this project
```

### execution and module boundaries

the installer runs as a series of sourced bash scripts. each script file is responsible for one component and one component only. the main `install.sh` wires things together and should never contain direct installation logic itself. `terminal.sh` and `desktop.sh` use glob loops over their respective directories, so adding a new component is as simple as dropping a new `.sh` file in the right place. no script may assume it is being run from a specific working directory — always use absolute paths rooted at `$JUSTBUNTU_PATH` or `$HOME`.

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
