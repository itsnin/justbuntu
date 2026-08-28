# JustBuntu

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Ubuntu](https://img.shields.io/badge/ubuntu-26.04%2B-orange.svg)](https://ubuntu.com)
[![Shell](https://img.shields.io/badge/shell-bash-lightgrey.svg)](https://www.gnu.org/software/bash/)

## The Project

JustBuntu is a single-command provisioning system that transforms a fresh Ubuntu installation into a configured web development environment. It addresses the enduring problem that every developer faces when starting from a clean operating system: hours of repetitive configuration, package installation, and environment tuning that yield no productive value in themselves.

Rather than offering a heavily themed or opinionated aesthetic layer, JustBuntu focuses on what matters for development work: reliable tool installation, sensible baseline configuration, and an architecture that respects the user's desire to customize their own system on top of a stable foundation. The project is intentionally minimal — it installs what is necessary and nothing more, keeping the shell and desktop experience close to stock Ubuntu.

When GNOME is detected, JustBuntu installs desktop applications and a carefully curated set of shell customizations. On systems without GNOME, it degrades gracefully to terminal and development tools only.

## Design Principles

- **Minimal, not decorated.** Shell customization is kept to the absolute minimum required for the project's own commands to function. The user inherits a system that feels like Ubuntu, not a derivative distribution.
- **Explicit and reversible.** Every change the installer makes is understandable by reading the corresponding script file. Optional components are gated behind explicit user choice rather than silently included. Everything installed has a corresponding uninstall path.
- **One extension only.** On GNOME, exactly one third-party shell extension is installed: Spotlight. Default Ubuntu extensions may be disabled or configured, but no additional third-party extensions are added.

## What Gets Installed

### Terminal (always)

| Component | Purpose |
|-----------|---------|
| Ghostty | Modern GPU-accelerated terminal emulator |
| Bash | Shell configuration kept close to Ubuntu defaults |
| GitHub CLI | Git operations and repository management |
| Docker + lazydocker | Container runtime and management interface |
| fastfetch | System information display |

### Development Tools (selectable)

- **Python** — python3, pip, venv, development headers, plus the uv package manager
- **Rust** — installed via rustup
- **Node.js** — version 24 via nvm
- **Java** — default-jdk plus Maven
- **C/C++ Build Tools** — gcc, g++, clang, cmake, gdb, valgrind, llvm
- **PostgreSQL** — database server
- **Web Tools** — tidy, html-xml-utils, sassc

### Desktop (GNOME only)

- **Browser selection** — Chrome, Brave, or none
- **Code Editor** — Visual Studio Code
- **Notes** — Obsidian
- **Media** — VLC
- **File Sharing** — LocalSend
- **File Preview** — GNOME Sushi
- **Shell Extension** — Spotlight
- **System Tweaks** — settings, hotkeys, app grid organization

### Optional Applications (GNOME only)

JetBrains Toolbox, OBS Studio, Spotify, Web Apps (Chat GPT, Google Photos, Google Contacts, Tailscale)

### Databases (selectable)

MySQL, Redis, PostgreSQL — all running via Docker

## Installation

JustBuntu requires Ubuntu 26.04 LTS or newer on x86_64 architecture.

```bash
wget -qO- https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

Or with curl:

```bash
sudo apt install -y curl && curl -s https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

The bootstrap script installs `git`, `wget`, and `curl` automatically, clones the repository, and begins the installation process. During installation, the user is presented with a small number of interactive choices: whether to remove snapd, which development tools to install, which databases to provision, which browser to use, and which optional desktop applications to include.

## Post-Installation Usage

After installation, the management interface is available from any terminal:

```bash
justbuntu
```

The interface provides options to install additional development languages, databases, or optional applications; to update components; to uninstall components; and to access documentation.

## Contributing

There are many ways to participate in this project:

- [Submit bugs and feature requests](https://github.com/itsnin/justbuntu/issues)
- Review [source code changes](https://github.com/itsnin/justbuntu/pulls)
- Review the documentation and submit corrections or improvements

Before contributing, please read [AGENTS.md](AGENTS.md), which describes the project's design philosophy, architecture, code style, and verification discipline. All contributions are expected to follow those guidelines.

## License

This source code is available to everyone under the standard [MIT License](LICENSE).
