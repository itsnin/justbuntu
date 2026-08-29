# JustBuntu

> One command. A better Ubuntu.

[![License: MIT](https://img.shields.io/badge/License-MIT-00ADD8?style=flat-square)](LICENSE)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-26.04%2B-E95420?style=flat-square&logo=ubuntu)](https://ubuntu.com)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash)](https://www.gnu.org/software/bash/)
[![Last Commit](https://img.shields.io/github/last-commit/itsnin/justbuntu?style=flat-square&logo=github)](https://github.com/itsnin/justbuntu/commits/main)

---

## Install

**Requires:** Ubuntu 26.04 LTS or newer · x86_64

```bash
wget -qO- https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

With curl:
```bash
sudo apt install -y curl && curl -s https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

During setup you'll choose:
- Whether to remove `snapd`
- Which development tools to install
- Which optional desktop apps to include

---

## What It Does

JustBuntu turns a fresh Ubuntu install into what it should have been — configured but not constrained. No themes, no distractions. The desktop gets out of your way.

### Always Installed

| Component | What |
|-----------|------|
| **Shell** | Minimal bash profile, PATH setup, utility functions |
| **CLI tools** | fastfetch, btop, wget, curl, micro |
| **Git** | Sensible defaults configured |
| **Dev libs** | Common headers: ssl, ffi, zlib, bz2, lzma, readline, ncurses |
| **GitHub CLI** | Official `gh` command |

### Development Tools (Your Choice)

Python · Rust · Go · Node.js · Java · C/C++ Build Tools · PostgreSQL · Web Tools

### Desktop (GNOME Only)

**Core:** Ghostty terminal · Chrome or Brave · VS Code · Obsidian · Element · VLC · GNOME Boxes · GNOME Sushi · GNOME Tweaks · LocalSend

**Optional:** JetBrains Toolbox · OBS Studio · Spotify · Slack · Discord · Web Apps

**Web Apps:** ChatGPT · Google Photos · Google Contacts · Tailscale · Facebook · Messenger · Instagram · Reddit

**Shell:** Spotlight extension · Custom keybindings · Empty dash · App grid organization

---

## After Install

Run the management CLI from any terminal:

```bash
justbuntu
```

Options:
- **Install** — add more languages or apps
- **Update** — pull latest versions
- **Revert** — remove components individually
- **Migrate** — update JustBuntu itself

---

## Principles

- **Unobtrusive** — The desktop recedes. Shell changes are minimal.
- **Reversible** — Every provisioned component has a matching revert script.
- **One extension** — Only Spotlight. No bloat.
- **Inclusive** — Dev-first, but useful for everyone.

---

## Project Layout

```
bin/                  CLI entry points
lib/                  Reusable: config, shell-profile, desktop-entries
provision/            All setup logic
  orchestrate.sh      Main entry point
  core/               Validation, snapd choice, preferences
  terminal/           CLI tools, dev languages, git, shell
  desktop/            GUI apps, browser, shell extensions
    extensions/       Optional apps (Spotify, Slack, Discord, etc.)
revert/               Uninstall scripts (one per component)
```

---

## Docs

- [AGENTS.md](AGENTS.md) — Architecture and code standards
- [CONTRIBUTING.md](CONTRIBUTING.md) — How to contribute
- [SECURITY.md](SECURITY.md) — Security reporting

---

## License

[MIT](LICENSE)
