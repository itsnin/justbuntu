# JustBuntu

Turn a fresh Ubuntu installation into what it should have been by running a single command. JustBuntu is an opinionated take on what Ubuntu can be at its best — configured but not constrained, the desktop recedes rather than announces itself. No themes, no distractions, no layer demanding your attention. Just a system ready for whatever you intend to do with it.

Read the full documentation at **[itsnin.github.io/justbuntu](https://itsnin.github.io/justbuntu)**.

---

## Install

Requires Ubuntu 26.04 LTS or newer on x86_64.

```bash
wget -qO- https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

With curl:

```bash
sudo apt install -y curl && curl -s https://raw.githubusercontent.com/itsnin/justbuntu/main/bootstrap.sh | bash
```

---

## After Install

Run the management CLI from any terminal:

```bash
justbuntu
```

---

## Project Structure

| Directory | Purpose |
|-----------|---------|
| `bin/` | CLI entry points and subcommands |
| `config/` | Static configuration files |
| `provision/` | System provisioning logic |
| `provision/core/` | Foundation: validation, snapd choice, preferences |
| `provision/terminal/` | Terminal tools, languages, shell configuration |
| `provision/desktop/` | Desktop applications, browser, extensions |
| `provision/desktop/extensions/` | Optional applications (Spotify, Slack, Discord, etc.) |
| `revert/` | Revert scripts — one per provisioned component |
| `share/` | Shared assets: desktop entry generators and icons |
| `shell/` | Shell environment: PATH, aliases, functions |
| `skills/` | Agent skill definitions |

---

## Documentation

Please help improve JustBuntu's documentation at the [docs site repository](https://github.com/itsnin/justbuntu).

---

## Extras

While JustBuntu is opinionated by design, the open source community offers alternative customizations and extensions that you can use to adjust or enrich your experience.

---

## License

JustBuntu is released under the [MIT License](LICENSE).
