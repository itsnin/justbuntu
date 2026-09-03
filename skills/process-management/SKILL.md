# Process Management

## Background Processes

```bash
# Run in background, get PID
long_running_task &
TASK_PID=$!

# Wait for it to complete
wait "$TASK_PID"
TASK_EXIT=$?

# Run multiple in parallel, wait for all
task1 &
task2 &
task3 &
wait
```

## Signal Handling with Trap

```bash
cleanup() {
    local signal="$1"
    [[ -n "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
    [[ -n "$BG_PID" ]] && kill "$BG_PID" 2>/dev/null
    exit 1
}

trap 'cleanup SIGINT' INT
trap 'cleanup SIGTERM' TERM
trap 'cleanup EXIT' EXIT
```

## Common Signals

| Signal | Number | Meaning |
|--------|--------|---------|
| `SIGINT` | 2 | Ctrl+C pressed |
| `SIGTERM` | 15 | Graceful termination request |
| `SIGKILL` | 9 | Force kill (cannot be trapped) |
| `SIGHUP` | 1 | Terminal disconnected |

## Avoiding Zombies

Always `wait` for background processes you start, or disown them:

```bash
fire_and_forget &
disown
```

## `kill` Patterns

```bash
# Graceful shutdown request first
kill "$PID"                    # SIGTERM
sleep 2
if kill -0 "$PID" 2>/dev/null; then
    kill -9 "$PID"             # SIGKILL — last resort only
fi
```

## GNOME Extension Preferences via CLI

1. Copy the extension's schema XML files from `~/.local/share/gnome-shell/extensions/<uuid>/schemas/*.gschema.xml` to `/usr/share/glib-2.0/schemas/`
2. Run: `sudo glib-compile-schemas /usr/share/glib-2.0/schemas/`
3. Set preferences: `gsettings set org.gnome.shell.extensions.<name> <key> <value>`

Always verify key names against the actual schema XML files shipped with each extension.

## Homebrew on Linux

Install path: `/home/linuxbrew/.linuxbrew`. To add to current shell:

```bash
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi
```

When spawning subshells (e.g., `bash -c "..."` inside `gnome-session-inhibit`), the parent's PATH additions are NOT inherited. Re-run the shellenv eval inside the subshell.

## Git Identity Configuration

Never prompt interactively for git user.name/user.email. Accept them via environment variables:

```bash
if [[ -n "${JUSTBUNTU_GIT_USER_NAME:-}" ]]; then
  git config --global user.name "$JUSTBUNTU_GIT_USER_NAME"
fi
if [[ -n "${JUSTBUNTU_GIT_USER_EMAIL:-}" ]]; then
  git config --global user.email "$JUSTBUNTU_GIT_USER_EMAIL"
fi
```

## Known GNOME Keybinding Conflicts

**Super+V** — opens notification list. Schema: `org.gnome.shell.keybindings`, Key: `toggle-message-tray`. Default: `['<Super>v', '<Super>m']`. Fix: keep only `Super+M`, free up `Super+V` for clipboard managers.

**Super+Period (.)** — opens IBus emoji picker. Schema: `org.freedesktop.ibus.panel.emoji`, Key: `hotkey`. Default: `['<Super>period']`. Fix: disable entirely so emoji-copy extension can use it.
