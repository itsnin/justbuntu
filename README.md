<h1 align="center">JustBuntu</h1>

<p align="center">
  <strong>Turn a fresh Ubuntu installation into what it should have been.</strong>
</p>

<p align="center">
  <a href="https://itsnin.github.io/justbuntu"><strong>Documentation</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/itsnin/justbuntu/releases">Releases</a>
  &nbsp;·&nbsp;
  <a href="./CONTRIBUTING.md">Contributing</a>
</p>

---

## About

JustBuntu is a one-command setup that turns a fresh Ubuntu 26.04 LTS or newer installation into what Ubuntu should have been all along. It is opinionated where opinions reduce friction, and restrained where opinions would impose themselves. The result is a system that arrives configured but not constrained.

While crafted with developers as the primary audience, it avoids narrow specialization and remains approachable for anyone who wants a clean, capable desktop. No themes, no distractions, no layer demanding your attention. Just a system ready for whatever you intend to do with it.

## Quick Install

Requires Ubuntu 26.04 LTS or newer on x86_64.

```bash
wget -qO- https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

## After Installation

Run the management CLI from any terminal:

```bash
justbuntu
```

The menu provides options for installing additional components, updating JustBuntu itself, reverting individual components, and accessing the documentation.

## Project Structure

| Path | Purpose |
|------|---------|
| `install.sh` | Main entry point — full installation orchestrator |
| `lib/` | Core infrastructure — logging, error handling |
| `core/` | Sub-orchestrators, validation, preference gathering |
| `provision/` | Forward action — install and configure (mirrors `revert/`) |
| `provision/general/install/` | Software installation scripts |
| `provision/general/install/prerequisites/` | Gum + Homebrew (mandatory dependencies) |
| `provision/general/install/terminal/` | Terminal tools, languages, dev libraries |
| `provision/general/install/apps/` | Cross-desktop applications, browsers, AI tools, web apps |
| `provision/general/install/apps/ai/` | AI assistant installers |
| `provision/general/install/apps/optional/` | Third-party .deb downloaders (Slack, Discord, JetBrains, etc.) |
| `provision/gnome/install/` | GNOME-only software (Boxes, Sushi, Tweaks, extensions) |
| `provision/general/configure/` | System configuration (no package install) |
| `provision/gnome/configure/` | GNOME-specific settings (keybindings, dock, app grid, default terminal) |
| `revert/` | Undo action — uninstall and deconfigure (mirrors `provision/`) |
| `revert/general/uninstall/` | Package removal (37 scripts) |
| `revert/general/deconfigure/` | Settings reset (13 scripts) |
| `bin/` | CLI entry points (`justbuntu` command) |
| `shell/` | Bash environment configuration |
| `share/` | Desktop entries, icons |
| `config/` | Bashrc snippet |
| `skills/` | Agent skill definitions |


## Contributing

Contributions of all types are welcome — bug fixes, new features, documentation improvements, design proposals. Before starting, please read the [contributor guide](./CONTRIBUTING.md) and the [agent standards](./AGENTS.md) which describe the project's design philosophy, architecture, code style, and verification discipline.

## Code of Conduct

This project follows the [Contributor Covenant](./CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Security

For security vulnerabilities, please do not open a public issue. See the [security policy](./SECURITY.md) for the private reporting process.

## License

JustBuntu is released under the [MIT License](./LICENSE).
