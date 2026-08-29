# JustBuntu

Single-command provisioning for Ubuntu — the desktop experience Ubuntu should have shipped with.

[![License](https://img.shields.io/badge/License-MIT-00ADD8?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-26.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Last Commit](https://img.shields.io/github/last-commit/itsnin/justbuntu?style=for-the-badge&logo=github)](https://github.com/itsnin/justbuntu/commits/main)

## Installation

JustBuntu requires Ubuntu 26.04 LTS or newer on x86_64 architecture.

```bash
wget -qO- https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

Or with curl:

```bash
sudo apt install -y curl && curl -s https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

The bootstrap script installs `git`, `wget`, and `curl` automatically, clones the repository, and begins installation. During the process, you will be presented with a small number of interactive choices: whether to remove snapd, which development tools to install, which databases to provision, and which optional desktop applications to include.

## The Project

JustBuntu is what Ubuntu should have been all along — an operating system that respects your attention and gets out of your way. It takes a deliberate stance: hold opinions where they reduce friction, step back where they would impose them. The result is a system that arrives configured but not constrained; opinionated in its defaults, yet generous in its reach.

At its core, JustBuntu eliminates the hours of repetitive configuration that greet every user of a fresh operating system. It installs the tools people actually need, sets sensible baselines, and then fades into the background. No themes. No distractions. No aesthetic layer demanding your attention. Just a system ready for whatever you intend to do with it.

While crafted with developers as the primary audience, JustBuntu avoids narrow specialization. The tools and conventions it establishes serve anyone who wants a clean, capable desktop — writers, designers, students, and tinkerers all find a foundation they can build on.

When GNOME is detected, JustBuntu installs desktop applications and a carefully curated set of shell customizations. On systems without GNOME, it degrades gracefully to terminal and core tools only.

## Design Principles

- **Unobtrusive by design.** The desktop recedes. Shell customization is kept to the absolute minimum required for the project's own commands to function. What remains is unmistakably Ubuntu, refined rather than replaced.
- **Explicit and reversible.** Every change the installer makes is understandable by reading the corresponding script file. Optional components are gated behind explicit user choice rather than silently included. Everything installed has a corresponding uninstall path.
- **One extension only.** On GNOME, exactly one third-party shell extension is installed: Spotlight. Default Ubuntu extensions may be disabled or configured, but no additional third-party extensions are added.
- **Inclusive defaults.** The baseline configuration serves developers first, but the system remains approachable and useful for non-developers. Opinions are held lightly; utility is held strongly.

## Post-Installation Usage

After installation, the management interface is available from any terminal:

```bash
justbuntu
```

The interface provides options to install additional development languages, databases, or optional applications; to update components; to uninstall components; and to access documentation.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for ways to participate in the project.

## License

This source code is available to everyone under the standard [MIT License](LICENSE).
