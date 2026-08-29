# JustBuntu

> Single-command provisioning for Ubuntu — the desktop experience Ubuntu should have shipped with.

[![License](https://img.shields.io/badge/License-MIT-00ADD8?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-26.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Last Commit](https://img.shields.io/github/last-commit/itsnin/justbuntu?style=for-the-badge&logo=github)](https://github.com/itsnin/justbuntu/commits/main)

---

## Philosophy

JustBuntu is what Ubuntu should have been all along — an operating system that respects your attention and gets out of your way. It takes a deliberate stance: hold opinions where they reduce friction, step back where they would impose them. The result is a system that arrives configured but not constrained; opinionated in its defaults, yet generous in its reach.

At its core, JustBuntu eliminates the hours of repetitive configuration that greet every user of a fresh operating system. It installs the tools people actually need, sets sensible baselines, and then fades into the background. No themes. No distractions. No aesthetic layer demanding your attention. Just a system ready for whatever you intend to do with it.

### Design Principles

| Principle | Description |
|-----------|-------------|
| **Unobtrusive by design** | The desktop recedes. Shell customization is kept to the absolute minimum required for the project's own commands to function. What remains is unmistakably Ubuntu, refined rather than replaced. |
| **Explicit and reversible** | Every change the installer makes is understandable by reading the corresponding script file. Optional components are gated behind explicit user choice rather than silently included. Everything provisioned has a corresponding revert path. |
| **One extension only** | On GNOME, exactly one third-party shell extension is provisioned: Spotlight. Default Ubuntu extensions may be disabled or configured, but no additional third-party extensions are added. |
| **Inclusive defaults** | The baseline configuration serves developers first, but the system remains approachable and useful for non-developers. Opinions are held lightly; utility is held strongly. |

---

## Quick Start

### Requirements

- Ubuntu 26.04 LTS or newer
- x86_64 architecture
- Bash shell

### Installation

```bash
wget -qO- https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

Or with curl:

```bash
sudo apt install -y curl && curl -s https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

The bootstrap script installs `git`, `wget`, and `curl` automatically, clones the repository, and begins provisioning. During the process, you will be presented with a small number of interactive choices:

1. Whether to remove `snapd`
2. Which development tools to install
3. Which optional desktop applications to include

When GNOME is detected, JustBuntu provisions desktop applications and a carefully curated set of shell customizations. On systems without GNOME, it degrades gracefully to terminal and core tools only.

---

## What Gets Provisioned

### Core (Always)

| Component | Purpose |
|-----------|---------|
| **System validation** | Confirms Ubuntu 26.04+ on x86_64 |
| **snapd choice** | User decides: remove or keep |
| **kdump-tools purge** | Frees reserved memory on desktop systems |
| **Shell profile** | Minimal bash configuration with PATH, aliases, and utility functions |
| **Git configuration** | Sensible defaults for version control |
| **CLI utilities** | fastfetch, btop, wget, curl, micro |
| **System libraries** | Common development headers and libraries |
| **GitHub CLI** | Official GitHub command-line interface |

### Development Tools (User-Selectable)

Python · Rust · Go · Node.js · Java · C/C++ Build Tools · PostgreSQL · Web Tools

### Desktop (GNOME Only)

| Category | Applications |
|----------|-------------|
| **Terminal** | Ghostty (GPU-accelerated) |
| **Browsers** | Chrome, Brave Origin (user choice) |
| **Code & IDE** | VS Code, JetBrains Toolbox (optional) |
| **Productivity** | Obsidian, Element (Matrix client) |
| **Media** | VLC, Spotify (optional) |
| **Utilities** | GNOME Boxes, GNOME Sushi, GNOME Tweaks, LocalSend |
| **Creative** | OBS Studio (optional), Slack (optional) |
| **Web Apps** | ChatGPT, Google Photos, Google Contacts, Tailscale, Facebook, Messenger, Instagram, Reddit (user choice) |
| **Shell** | Spotlight extension, custom keybindings, dock configuration, app grid organization |

---

## Post-Installation

The management interface is available from any terminal:

```bash
justbuntu
```

The interface provides options to:

- **Install** additional development languages or optional applications
- **Update** components to their latest versions
- **Revert** components individually
- **Migrate** to a newer version of JustBuntu

---

## Project Structure

```
justbuntu/
├── bin/                    # CLI entry points
│   ├── justbuntu           # Main command
│   └── commands/           # Subcommand implementations
├── lib/                    # Reusable library components
│   ├── configuration/      # Static configuration files
│   ├── desktop-entries/    # .desktop entry generators
│   └── shell-profile/      # Shell environment configuration
├── provision/              # All provisioning logic
│   ├── orchestrate.sh      # Primary orchestrator
│   ├── orchestrate-terminal.sh
│   ├── orchestrate-desktop.sh
│   ├── core/               # Foundation: validation, snapd, kdump, preferences
│   ├── terminal/           # Terminal environment provisioning
│   └── desktop/            # Desktop environment provisioning
│       └── extensions/     # Optional desktop applications
├── revert/                 # Revert scripts for every provisioned component
└── skills/                 # Agent skill definitions
```

---

## Documentation

- [AGENTS.md](AGENTS.md) — Architecture, code style, and review discipline for contributors
- [CONTRIBUTING.md](CONTRIBUTING.md) — How to participate in the project
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) — Community standards
- [SECURITY.md](SECURITY.md) — Security policy and reporting

---

## License

This source code is available to everyone under the standard [MIT License](LICENSE).
