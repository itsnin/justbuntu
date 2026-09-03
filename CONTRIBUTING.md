# Contributing to JustBuntu

There are many ways to participate in this project.

## Reporting Issues

- [Submit bugs and feature requests](https://github.com/itsnin/justbuntu/issues)
- Use the appropriate issue template when creating a new report

## Code Contributions

- Review [source code changes](https://github.com/itsnin/justbuntu/pulls)
- Submit pull requests with bug fixes or new features

Before contributing code, please read [AGENTS.md](AGENTS.md), which describes the project's design philosophy, architecture, code style, and verification discipline. All contributions are expected to follow those guidelines.

## Documentation

Review the documentation and submit corrections or improvements.

## Architecture Overview

```mermaid
flowchart TD
    A[bootstrap.sh] --> B[orchestrate.sh]
    B --> C[validate-system.sh]
    C --> D[provision-gum.sh]
    D --> E[provision-homebrew.sh]
    E --> F[gather-preferences.sh\nALL interactive choices]
    F --> G[sudo -v\nrefresh credentials]
    G --> H[configure-snapd.sh]
    H --> I[purge-kdump.sh]
    I --> J[orchestrate-terminal.sh\napt update/upgrade + all terminal tools]
    J --> K{GNOME detected?}
    K -->|No| L[Done]
    K -->|Yes| M[gnome-session-inhibit\nsubshell]
    M --> N[orchestrate-desktop.sh]
    N --> O[configure-keybindings.sh]
    O --> P[configure-shell-extensions.sh\ninteractive popups]
    P --> Q[All other desktop scripts\nvia glob loop]
    Q --> R[Reboot prompt]
    R --> L
```

## Desktop Phase Ordering

Keybindings and extensions run in a specific order because extensions may override base shortcuts:

```mermaid
flowchart LR
    A[configure-keybindings.sh\nSets Super+1-9 = workspaces\nNo user interaction] --> B[configure-shell-extensions.sh\nSpace Bar clears Super+1-9\nInteractive popups]
    B --> C[All other desktop scripts\nGlob loop, alphabetical]
```

## Pull Request Checklist

- All shell scripts pass `bash -n` syntax check
- Comments are lowercase with no punctuation unless meaning requires it
- No references to forbidden project names anywhere
- No `sudo` added to commands that do not require it
- No `sudo` removed from commands that genuinely need it
- Newly installed components have corresponding uninstall scripts
- Tested on Ubuntu 26.04 LTS or equivalent
