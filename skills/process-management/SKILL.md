# Process Management

## Overview

Manage background processes, job control, signals, and waiting correctly.

**Confidence**: Verified via bash manual knowledge and general Unix process model. From training data (may be outdated or wrong for edge cases).

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
wait  # waits for ALL background jobs
```

## Wait for Specific PIDs

```bash
pids=()

long_task1 &
pids+=($!)

long_task2 &
pids+=($!)

# Wait for each and collect exit codes
for pid in "${pids[@]}"; do
    if wait "$pid"; then
        echo "PID $pid succeeded"
    else
        echo "PID $pid failed (exit $?)" >&2
    fi
done
```

## Signal Handling with Trap

```bash
# Handle signals for graceful shutdown
cleanup() {
    local signal="$1"
    echo "received $signal, cleaning up..." >&2
    [[ -n "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
    [[ -n "$BG_PID" ]] && kill "$BG_PID" 2>/dev/null
    exit 1
}

trap 'cleanup SIGINT' INT
trap 'cleanup SIGTERM' TERM
trap 'cleanup EXIT' EXIT
```

## Common Signals

| Signal | Number | Meaning | Default Action |
|--------|--------|---------|----------------|
| `SIGINT` | 2 | Ctrl+C pressed | Terminate |
| `SIGTERM` | 15 | Graceful termination request | Terminate |
| `SIGKILL` | 9 | Force kill (cannot be trapped) | Terminate |
| `SIGHUP` | 1 | Terminal disconnected | Terminate |
| `SIGERR` | — | Bash: command returned non-zero (for `trap`) | N/A |

## Process Substitution

```bash
# <(cmd) — treat command output as a file
diff <(sort file1) <(sort file2)

# >(cmd) — treat command input as a file
tee >(gzip > backup.gz) > original.txt
```

## Avoiding Zombies

When a background process finishes but the parent doesn't `wait` for it, it becomes a zombie. Always `wait` for background processes you start, or disown them if you truly don't care:

```bash
# Fire and forget — disown so parent doesn't create zombies
fire_and_forget &
disown
```

## `kill` Patterns

```bash
# Graceful shutdown request
kill "$PID"                    # SIGTERM
sleep 2
if kill -0 "$PID" 2>/dev/null; then
    # Still running, force kill
    kill -9 "$PID"             # SIGKILL — last resort only
fi
```

**Self-challenge**: Are you using `kill -9` as the first option? It should be the LAST option — processes killed with SIGKILL cannot clean up temp files, flush buffers, or release locks gracefully.

## GNOME Extension Preferences via CLI

The standard method to configure GNOME shell extensions from scripts:

1. Copy the extension's schema XML files from ~/.local/share/gnome-shell/extensions/<uuid>/schemas/*.gschema.xml to /usr/share/glib-2.0/schemas/
2. Run: sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
3. Set preferences: gsettings set org.gnome.shell.extensions.<name> <key> <value>

Important: Always verify key names against the actual schema XML files shipped with each extension. For example, Space Bar "Toggle overview" is `toggle-overview` in the behavior schema, NOT in the shortcuts schema. Guessing key names leads to silent failures.

This is the proper system-native approach. Using --schemadir per call or dconf write are workarounds, not the standard method.

## Homebrew on Linux

Install path: `/home/linuxbrew/.linuxbrew`. To add to current shell:
```bash
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi
```
Add this check to shell config files for persistence. When spawning subshells (e.g., `bash -c "..."` inside `gnome-session-inhibit`), the parent's PATH additions are NOT inherited — re-run the shellenv eval inside the subshell.

## Git Identity Configuration

Never prompt interactively for git user.name/user.email. Instead, accept them via environment variables:
```bash
if [[ -n "${JUSTBUNTU_GIT_USER_NAME:-}" ]]; then
  git config --global user.name "$JUSTBUNTU_GIT_USER_NAME"
fi
if [[ -n "${JUSTBUNTU_GIT_USER_EMAIL:-}" ]]; then
  git config --global user.email "$JUSTBUNTU_GIT_USER_EMAIL"
fi
```

## GNOME Extension Configuration

### Schema Verification
Never trust documentation or memory for extension gsettings keys. Always extract the actual ZIP and read the schema XML:
```bash
unzip -q extension.zip -d /tmp/ext/
cat /tmp/ext/schemas/*.gschema.xml
```
This reveals exact key names, types, defaults, and enums.

### Standard Installation Pattern
```bash
gext install extension@uuid
# copy schema system-wide
sudo cp ~/.local/share/gnome-shell/extensions/extension@uuid/schemas/*.xml /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
# configure via gsettings
gsettings set org.gnome.shell.extensions.extension-name key value
```

### Known GNOME Keybinding Conflicts

**Super+V** — opens notification list (message tray):
```bash
# Schema: org.gnome.shell.keybindings
# Key: toggle-message-tray
# Default: ['<Super>v', '<Super>m']
# Fix: keep only Super+M, free up Super+V for clipboard managers
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']"
```

**Super+Period (.)** — opens IBus emoji picker:
```bash
# Schema: org.freedesktop.ibus.panel.emoji
# Key: hotkey
# Default: ['<Super>period']
# Fix: disable entirely so emoji-copy extension can use it
gsettings set org.freedesktop.ibus.panel.emoji hotkey "@as []"
```
