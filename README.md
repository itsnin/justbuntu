# JustBuntu

Turn a fresh Ubuntu installation into a configured web development system by running a single command. JustBuntu sets up your terminal, development tools, and desktop applications with sensible defaults.

**Maintainer**: nin (Nahian I. Nafseen)

## Requirements

- **Ubuntu 26.04 LTS or newer** — hard requirement
- **x86_64 architecture**
- **Bash** shell (preinstalled on all Ubuntu systems)

If GNOME is detected, desktop tools and customizations will be installed. On systems without GNOME, only terminal and development tools will be installed.

## Installation

Run this command in your terminal:

```bash
wget -qO- https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

Or with `curl` (installs curl first if needed):

```bash
sudo apt install -y curl && curl -s https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

The script runs explicitly in Bash regardless of your default shell. Bootstrap installs `git`, `wget`, and `curl` automatically.

## Documentation

Visit the project website: [itsnin.github.io/justbuntu](https://itsnin.github.io/justbuntu)

## What Gets Installed

### Terminal (always installed)
- **Ghostty** — fast, modern GPU-accelerated terminal emulator
- **Shell**: Bash kept close to Ubuntu defaults with minimal changes
- **Git Tools**: GitHub CLI
- **Container Tools**: Docker, lazydocker
- **System Info**: fastfetch

### Development Tools (selectable)
- **Python** — python3, pip, venv, dev + uv package manager
- **Rust** — rustup
- **Node.js** — nvm with Node.js 24
- **Java** — default-jdk + Maven
- **C/C++ Build Tools** — gcc, g++, clang, cmake, gdb, valgrind, llvm
- **PostgreSQL** — database server
- **Web Tools** — tidy, html-xml-utils, sassc

### Desktop Applications (GNOME only)
- **Browser**: Google Chrome
- **Code Editor**: VS Code
- **Notes**: Obsidian
- **Media Player**: VLC
- **Local File Sharing**: LocalSend
- **File Preview**: Gnome Sushi
- **GNOME Extension**: Spotlight
- **GNOME Tweaks**: Settings, hotkeys, dock, app grid organization

### Optional Applications (GNOME only)
- JetBrains Toolbox
- OBS Studio
- Spotify
- Web Apps (Chat GPT, Google Photos, Google Contacts, Tailscale)

### Databases (selectable)
MySQL, Redis, PostgreSQL (via Docker)

## Post-Installation Usage

After installation, run the management interface:

```bash
justbuntu
```

Options:
- Install additional development languages, databases, or optional applications
- Update components
- Uninstall components
- Access documentation
- 
## License

JustBuntu is released under the [MIT License](LICENSE).
