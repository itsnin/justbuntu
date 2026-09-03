# Contributing to JustBuntu

There are several ways to contribute to this project. All contributions are appreciated.

## Ways to Contribute

1. **[Report bugs or request features](#reporting-issues)**
2. **[Submit code changes](#code-contributions)**
3. **[Improve documentation](#documentation)**
4. **[Review pull requests](https://github.com/itsnin/justbuntu/pulls)**

---

## Reporting Issues

Before filing a new issue, please search existing issues to avoid duplicates. If you find a matching report, upvote it or add a comment with your specific context.

When reporting a bug, include:
- Ubuntu version and architecture
- Whether you are running GNOME or a different desktop environment
- Relevant log output from `/var/log/justbuntu-install.log`
- Steps to reproduce the problem

Issue templates are provided to guide you through the necessary information.

| Issue Type | Where to File |
|------------|--------------|
| Installation failures, provisioning bugs, feature requests | [GitHub issues](https://github.com/itsnin/justbuntu/issues) |
| Security vulnerabilities | See [SECURITY.md](./SECURITY.md) for private reporting |

---

## Code Contributions

### Before You Start

1. **File or find an issue** — This gives us a chance to provide feedback before you invest time.
2. **Read the standards** — [AGENTS.md](./AGENTS.md) describes the design philosophy, architecture, code style, and verification discipline. All contributions are expected to follow these guidelines.
3. **Fork and clone** the repository.

### Development Workflow

1. Create a feature branch from `main`
2. Make your changes
3. Verify:
   ```bash
   # Syntax check all shell scripts
   find . -name "*.sh" -exec bash -n {} \;

   # Lint with ShellCheck
   find . -name "*.sh" -exec shellcheck {} +
   ```
4. Test on Ubuntu 26.04 LTS or equivalent
5. Submit a pull request

### Pull Request Checklist

- [ ] All shell scripts pass `bash -n` syntax check
- [ ] ShellCheck passes, or each warning is understood and justified
- [ ] Comments follow the project style — sentence case, proper nouns capitalized, light punctuation, explain why not what
- [ ] Maximum three consecutive comment lines without intervening code
- [ ] No references to forbidden project names anywhere in code or docs
- [ ] No `sudo` added to commands that do not require it
- [ ] No `sudo` removed from commands that genuinely need it
- [ ] Newly provisioned components have corresponding revert scripts
- [ ] New scripts start with `#!/usr/bin/env bash` and `set -euo pipefail`
- [ ] Tested on Ubuntu 26.04 LTS or equivalent

---

## Architecture Overview

```mermaid
flowchart TD
    %% Color definitions — readable in both light and dark mode
    classDef entry fill:#1e3a5f,stroke:#4a90d9,stroke-width:2px,color:#ffffff
    classDef core fill:#2d5016,stroke:#6aa84f,stroke-width:2px,color:#ffffff
    classDef interactive fill:#5c3d2e,stroke:#d4a373,stroke-width:2px,color:#ffffff
    classDef terminal fill:#3d1f5c,stroke:#9b7cc9,stroke-width:2px,color:#ffffff
    classDef desktop fill:#1f4d4d,stroke:#5fb3b3,stroke-width:2px,color:#ffffff
    classDef decision fill:#5c1a1a,stroke:#c95a5a,stroke-width:2px,color:#ffffff
    classDef done fill:#333333,stroke:#777777,stroke-width:2px,color:#ffffff

    A[bootstrap.sh]:::entry --> B[orchestrate.sh]:::core
    B --> C[validate-system.sh]:::core
    C --> D[provision-gum.sh]:::core
    D --> E[provision-homebrew.sh]:::core
    E --> F[gather-preferences.sh<br/>All interactive choices]:::interactive
    F --> G[sudo -v<br/>Refresh credentials]:::core
    G --> H[configure-snapd.sh]:::core
    H --> I[purge-kdump.sh]:::core
    I --> J[orchestrate-terminal.sh<br/>apt update + all terminal tools]:::terminal
    J --> K{GNOME detected?}:::decision
    K -->|No| L[Done]:::done
    K -->|Yes| M[gnome-session-inhibit<br/>subshell]:::desktop
    M --> N[orchestrate-desktop.sh]:::desktop
    N --> O[configure-keybindings.sh]:::desktop
    O --> P[configure-shell-extensions.sh<br/>Interactive popups]:::interactive
    P --> Q[All other desktop scripts<br/>via glob loop]:::desktop
    Q --> R[Reboot prompt]:::interactive
    R --> L
```

---

## Desktop Phase Ordering

Keybindings and extensions run in a specific order because extensions may override base shortcuts. Running keybindings first establishes the baseline, then extensions can selectively clear or replace those shortcuts without conflicts.

```mermaid
flowchart LR
    %% Color definitions
    classDef step1 fill:#1e3a5f,stroke:#4a90d9,stroke-width:2px,color:#ffffff
    classDef step2 fill:#5c3d2e,stroke:#d4a373,stroke-width:2px,color:#ffffff
    classDef step3 fill:#2d5016,stroke:#6aa84f,stroke-width:2px,color:#ffffff

    A[configure-keybindings.sh<br/>Sets Super+1-9 = workspaces<br/>No user interaction]:::step1 --> B[configure-shell-extensions.sh<br/>Space Bar clears Super+1-9<br/>Interactive popups]:::step2
    B --> C[All other desktop scripts<br/>Glob loop, alphabetical]:::step3
```

---

## Documentation

Documentation improvements are always welcome. This includes:
- The [README](./README.md)
- This contributing guide
- [AGENTS.md](./AGENTS.md) — design philosophy and standards
- The [documentation site](https://itsnin.github.io/justbuntu)

---

## Thank You

Thank you in advance for your contribution. Every bug report, documentation fix, and code change helps make JustBuntu better for everyone.
