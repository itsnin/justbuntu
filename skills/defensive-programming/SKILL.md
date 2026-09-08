# Defensive Programming

## Core Principles

1. Treat all input as untrusted — arguments, environment variables, file contents, command output
2. Validate early, fail clearly — check preconditions before doing work
3. Design for idempotency — safe to run multiple times
4. Support dry-run mode — show what would change without changing anything
5. Clean up after yourself — use `mktemp` + `trap` for temp files
6. Check dependencies exist — verify required commands before using them

## Input Validation

```bash
# Validate argument count
if [[ $# -lt 2 ]]; then
    echo "usage: $0 <source> <destination>" >&2
    exit 1
fi

# Validate file existence
if [[ ! -f "$source_file" ]]; then
    echo "error: source file not found: $source_file" >&2
    exit 1
fi

# Validate numeric input
if ! [[ "$count" =~ ^[0-9]+$ ]]; then
    echo "error: count must be a positive integer, got: $count" >&2
    exit 1
fi

# Validate against allowlist
case "$action" in
    install|remove|update) ;;
    *) echo "error: invalid action: $action" >&2; exit 1 ;;
esac
```

## Dependency Checking

```bash
if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required but not installed" >&2
    exit 1
fi
```

## Safe Temporary Files

```bash
TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT ERR INT TERM
```

Never use predictable temp paths like `/tmp/script.tmp`. They are race-condition vulnerabilities.

## Dry-Run Pattern

```bash
DRY_RUN="${DRY_RUN:-0}"

run_cmd() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}
```

## Idempotency Checks

```bash
# Only install if not already present
if ! command -v btop >/dev/null 2>&1; then
    sudo apt install -y btop
fi

# Only create directory if it doesn't exist
[[ -d "$target_dir" ]] || mkdir -p "$target_dir"
```

## Desktop Entries Need Absolute Paths

Desktop-launched applications inherit their environment from the systemd user session, not from `.bashrc`. Always use absolute paths in `.desktop` Exec= lines.

## Network Install Commands Need Robustness

When piping curl into bash for third-party installers, always add retry logic and graceful failure:

```bash
if curl -fsSL --retry 3 --retry-delay 5 https://example.com/install.sh | bash; then
  echo "installed"
else
  echo "install failed (continuing)"
fi
```

## GitHub Release Downloads — MANDATORY PATTERN

For ANY package fetched from GitHub releases, ALWAYS query the last 10 releases and iterate to find a matching asset. The "latest" release is frequently broken, missing assets, or a prerelease.

```bash
DEB_URL=$(curl -fsSL --retry 2 "https://api.github.com/repos/OWNER/REPO/releases?per_page=10" | python3 -c "
import json, sys
for release in json.load(sys.stdin):
    if release.get('prerelease', False):
        continue
    for asset in release.get('assets', []):
        name = asset.get('name', '')
        if name.endswith('.deb') and 'amd64' in name.lower():
            print(asset['browser_download_url'])
            sys.exit(0)
sys.exit(1)
")
```

## Executable Bits and Git

CLI entry points MUST have the executable bit set AND tracked in git:

```bash
chmod +x bin/script
git add bin/script
git ls-files --stage bin/script   # verify: 100755 = executable
```

Add defense-in-depth `chmod +x` in provisioning scripts.

## Desktop Entries (.desktop files)

After creating or modifying `.desktop` files, ALWAYS refresh the desktop database:

```bash
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
```

## Web App Icons

Google's S2 favicon service returns generic icons for Google's own products. Use the homarr-labs dashboard-icons CDN for known apps:

```
https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-drive.png
https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-keep.png
https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-photos.png
https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png
https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/chatgpt.png
https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/facebook.png
https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/facebook-messenger.png
https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/instagram.png
https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/reddit.png
```

Fallback chain: CDN, then direct `/favicon.ico`, then Google S2 service.

## JetBrains Product Downloads

JetBrains Toolbox tarball structure: binary is INSIDE `bin/` subdirectory. Use `mv "$TOOLBOX_DIR"/bin/* target/`, NOT `mv "$TOOLBOX_DIR"/* target/`.

Never hardcode download URLs. Use official public API:

```bash
TOOLBOX_URL=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data['TBA'][0]['downloads']['linux']['link'])
")
```

Product codes: TBA=Toolbox App, IIU=IntelliJ Ultimate, PCP=PyCharm Professional.

Toolbox creates its own `.desktop` file on first launch at `~/.local/share/applications/`.


## Slack Desktop Downloads

Slack does not provide a clean "latest" URL. Parse the download page HTML to extract the current direct .deb URL:

```bash
SLACK_DEB_URL=$(curl -fsSL --retry 2 "https://slack.com/downloads/linux" | grep -oP 'https://downloads\.slack-edge\.com[^"]+amd64\.deb' | head -1)
```

Fallback: if the parse fails, skip gracefully with a warning rather than hardcoding a version that will become stale.



## Homebrew Non-Interactive Install

The official Homebrew installer is interactive by default. For automation:

```bash
# GOOD: official non-interactive mode
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# BAD: unreliable echo pipe
echo | /bin/bash -c "..."   # May hang on multiple prompts or sudo password
```

Homebrew on Linux installs to one of two locations depending on sudo access:
- `/home/linuxbrew/.linuxbrew/bin/brew` (system-wide, requires sudo)
- `$HOME/.linuxbrew/bin/brew` (user-local, no sudo needed)

Always check **both** paths when initializing `brew shellenv`.
## gum spin + Shell Builtins

`gum spin` (written in Go) spawns subprocesses via `os/exec`, which requires an actual executable file on `$PATH`. Shell builtins like `source`, `function`, `alias`, and shell keywords cannot be executed directly:

```bash
# BROKEN: source is a bash builtin, not a file on disk
gum spin --title "Working..." -- source ./script.sh

# FIXED: wrap through bash executable
gum spin --title "Working..." -- bash -c "source './script.sh'"
```

This also applies to shell functions — they only exist in the current shell's memory, not as files on disk. Always wrap in `bash -c`.

## Cross-Process Error Handling

Shell variables like `ERROR_HANDLING` do NOT cross process boundaries. When spawning a separate `bash -c "..."` process that re-sources error handling, the parent process's guard variable is untouched.

If the child process's error handler fires and the user chooses "Exit", the child must signal to the parent that the error was already handled. Options:

1. **Exit code 0**: Child exits 0 on user-initiated "Exit". Parent sees success, no ERR trap fires. Simplest, but masks the failure exit code.
2. **Sentinel file**: Child creates `/tmp/justbuntu-error-handled` before exiting. Parent's error handler checks for this file and suppresses re-fire if found.
3. **Specific exit code**: Child exits with code 42. Parent's `exit_handler` checks `(( exit_code != 42 ))` before firing.

## Variable Quoting Inside Command Substitutions

Inside `$(...)`, unquoted variables undergo word splitting and glob expansion. Always quote paths that could contain spaces or special characters:

```bash
# BAD: $HOME unquoted inside $(...)
eval "$($HOME/.linuxbrew/bin/brew shellenv bash)"

# GOOD: quoted
eval "$("$HOME/.linuxbrew/bin/brew" shellenv bash)"
```

This applies to `$HOME`, `$INSTALLER_FILE`, or any variable used as a command path inside a command substitution.


## Executable Bits in Git

Git tracks the executable permission bit (mode 100755 vs 100644). Zip files and some editors destroy this information.

**Critical files that MUST be executable**:
- CLI entry points invoked directly by name (e.g., `bin/justbuntu` on `$PATH`)
- Entry point scripts users might run as `./script.sh`

**Files that do NOT need to be executable**:
- Any script always invoked via `source` or `bash script.sh` (the vast majority in this codebase)

Verify in CI:
```yaml
- name: Verify critical files retain executable permission
  run: |
    for f in bin/justbuntu bootstrap.sh; do
      [ ! -x "$f" ] && echo "ERROR: $f must be executable" && exit 1
    done
```


## Idempotent Dotfile Modification

Never replace a user's `~/.bashrc` or `~/.profile`. Always append and use a guard to prevent duplication. Backup only once.

```bash
SOURCE_LINE="source "\$HOME/.local/share/justbuntu/shell/bash/rc""
BASHRC_FILE="$HOME/.bashrc"
BACKUP_FILE="$HOME/.bashrc.bak"

# Backup only if backup doesn't exist yet — preserves genuine original
if [ -f "$BASHRC_FILE" ] && [ ! -f "$BACKUP_FILE" ]; then
  cp "$BASHRC_FILE" "$BACKUP_FILE"
fi

# Create file if missing entirely
[ ! -f "$BASHRC_FILE" ] && touch "$BASHRC_FILE"

# Append only if not already present (idempotent across re-runs)
if ! grep -qxF "$SOURCE_LINE" "$BASHRC_FILE"; then
  {
    echo ""
    echo "# JustBuntu — load shell environment"
    echo "$SOURCE_LINE"
  } >> "$BASHRC_FILE"
fi
```

Key properties:
- User's existing customizations are preserved, not destroyed
- Second run does nothing (grep guard prevents duplication)
- Original backup never overwritten
- Works even if user has no bashrc at all

## Hard Dependencies Must Fail Hard

If a component is required for the script to continue (e.g., `gum` before interactive prompts), it must `exit 1` on failure, not just `echo` and continue.

```bash
# GOOD: hard fail with clear message
if ! sudo apt install -y gum; then
  echo "ERROR: gum installation failed. Gum is a required dependency." >&2
  exit 1
fi

# BAD: silent failure, subsequent commands crash mysteriously
sudo apt install -y gum || echo "gum install failed"
```

## Core Dependencies Have No Revert Scripts

JustBuntu core and its hard dependencies (gum) are permanent infrastructure. They must NOT have revert scripts. The "Reset All Components" feature reverts provisioned applications and settings, not the foundation that makes JustBuntu work.

If you add a new hard dependency: do NOT create a `revert-*.sh` for it.

## Cross-Process Error Handling via Sentinel File

When error handling spans a `bash -c` boundary, shell variables like `ERROR_HANDLING` cannot cross. Use a sentinel file:

```bash
# In child process error handler, "Exit" case:
touch /tmp/justbuntu-error-handled
exit 1  # Still report genuine failure

# In parent process error handler, at the very top:
if [[ -f /tmp/justbuntu-error-handled ]]; then
  rm -f /tmp/justbuntu-error-handled
  ERROR_HANDLING=true  # Also suppress EXIT trap re-fire
  return
fi
```

Clean up stale sentinels at startup: `rm -f /tmp/justbuntu-error-handled`

This preserves genuine failure exit codes while preventing double error menus.



## TTY Buffering with Tee and TUI Tools

When using `exec > >(tee -a logfile) 2>&1` to duplicate output to a log file, TUI tools like `gum choose` can appear "stuck." Their terminal escape sequences contain no newlines, so they sit in the pipe buffer between the script and `tee`.

**Fix**: Save the original TTY file descriptors before redirecting, and restore them for interactive phases:

```bash
# Before redirect: save original stdout (fd 3) and stderr (fd 4)
exec 3>&1
exec 4>&2
exec > >(tee -a "$LOGFILE") 2>&1

# For interactive TUI phases:
restore_tty() { exec >&3 2>&4; }
enable_logging() { exec > >(tee -a "$LOGFILE") 2>&1; }

restore_tty
gum choose ...  # Renders directly to TTY, no buffering
enable_logging
```

## Sudo Credential Caching Strategy

Default sudo timeout is 15 minutes. Interactive phases can easily exceed this.

```bash
# Cache credentials UPFRONT — before any provisioning that needs sudo
sudo -v

# ... long interactive phase ...

# Refresh credentials after user finishes making choices
sudo -v
```

This ensures sudo never prompts mid-install when the prompt might be invisible due to output redirection or buffering.


## curl|sh Installers With Interactive Prompts

Third-party install scripts piped through `curl | sh` sometimes ask post-install questions (e.g., "Start now?"). Since stdin is the script itself, these scripts open `/dev/tty` directly and will hang indefinitely waiting for input in an unattended context.

**Fix**: Download to temp file first, then pipe `yes n` to handle any prompts:

```bash
TMP_INSTALL=$(mktemp)
if curl -fsSL "$URL" -o "$TMP_INSTALL"; then
  yes n | bash "$TMP_INSTALL"
fi
rm -f "$TMP_INSTALL"
```



## PTY Wrapper for /dev/tty Prompts

Some third-party install scripts open `/dev/tty` directly for post-install prompts, completely bypassing stdin. Piping `yes n |` to the script's stdin has no effect because the script reads from the terminal device, not file descriptor 0.

**Fix**: Use the `script` command to create a pseudo-terminal, then pipe input to that:

```bash
echo n | script -q -c "sh $TMP_INSTALL" /dev/null
```

- `script` creates a PTY and runs the command inside it
- `-q` = quiet mode, no "Script started/stopped" messages
- `-c "command"` = command to run
- `/dev/null` = discard the typescript output file
- `echo n |` = provides input that reaches the PTY's /dev/tty

This is the only reliable way to answer prompts in scripts that explicitly open `/dev/tty`, short of using `expect`.


## Script Naming and Directory Conventions

Scripts are organized by action, not by "provisioning" (too vague/academic). Each filename clearly states what it does:

```
provision/general/install/      # Scripts that install software packages
provision/general/configure/    # Scripts that configure system settings (no package install)
core/         # Orchestrators, validation, interactive preference gathering
lib/      # Shared infrastructure (logging, error handling)
revert/       # Uninstall + deconfigure scripts (categorized into uninstall/ and deconfigure/ subdirs)
```

File prefix convention:
- Files in `provision/general/install/` — download and/or install software
- Files in `provision/general/configure/` — change settings via gsettings, dconf, config files, etc.
- `register-*.sh` — registers desktop entries, MIME types, etc.

Never use vague prefixes like `provision-` which could mean either install or configure.



## Homebrew Revert Coverage

Tools installed via `brew install` (lazygit, opencode, etc.) are NOT managed by apt.
Their revert scripts MUST include:
```bash
if command -v brew >/dev/null 2>&1; then
  brew uninstall formula-name 2>/dev/null || true
fi
```
alongside any apt purge or rm -rf cleanup.

## Revert Script Categorization

Revert scripts are organized by action, mirroring the install/configure split:

```
revert/
  uninstall/     # Removes installed packages (apt purge, brew uninstall, rm -rf binaries)
  deconfigure/   # Resets settings (gsettings reset, removes config files, .desktop entries)
  revert/all.sh   # Orchestrator — globs both subdirectories
```

Corollary: the orchestrator glob pattern must cover BOTH subdirectories:
```bash
for script in "$REVERT_DIR"/uninstall/revert-*.sh "$REVERT_DIR"/deconfigure/revert-*.sh; do
```

Never mix uninstall and deconfigure logic in the same revert script. Each script does one thing.

## Binary Installer Idempotency

Scripts that download and extract tarballs or move binaries into place must check if the binary already exists at the target location before attempting installation. On a second run, destination files may be locked by running processes or otherwise fail to overwrite.

```bash
# GOOD: check and skip if already present
if [ -x "$HOME/.local/share/AppTool/app-binary" ]; then
  echo "app tool already installed, skipping"
  return 0
fi
# ... download and extract ...
mv -f "$SOURCE_DIR"/bin/* "$TARGET_DIR/"   # -f flag prevents "file exists" errors
```

`apt install` is inherently idempotent and does not need this check. Direct binary extraction and `mv` operations do.

## Interactive Phases Must Stay Interactive

GNOME extension installation triggers popup confirmations in the shell UI. These require the user to be at the keyboard. Run extension installation immediately after the user finishes answering questions, not later in an "unattended" phase.

Correct order:
1. All interactive questions (last one = extensions yes/no)
2. Extension installation (popups appear, user clicks confirm)
3. sudo credential refresh
4. Unattended system changes (snapd removal, etc.)

## Sudo Prompts Need Clean TTY

`sudo -v` (credential caching) should run AFTER `restore_tty` so the password prompt renders directly to the terminal, not through a `tee` pipe buffer that could mangle it.

## Third-Party Apt Repositories

When a project offers an official apt repository, prefer it over hardcoded .deb downloads. It gives automatic updates via `apt upgrade`. Standard pattern:

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.example.com/key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/example.gpg
echo "deb [signed-by=/etc/apt/keyrings/example.gpg] https://repo.example.com/apt/ * *" | sudo tee /etc/apt/sources.list.d/example.list
sudo apt update && sudo apt install package
```

Revert must remove both the `.list` file and the keyring file, then run `apt update`.


## ShellCheck Configuration

For repos with intentional dynamic sourcing, suppress unfixable info notes globally via `.shellcheckrc` at repo root:

```
# Dynamic sourcing from variables — architectural, not a bug
disable=SC1090
# External files installed at runtime — ShellCheck cannot follow them
disable=SC1091
```

CI should use `severity: error` so only actual errors fail the build. Info and warning notes that are architectural false positives are handled by `.shellcheckrc`.

For shell startup files (`.bashrc`, `.profile`) that have no shebang, add a directive as line 1:

```bash
# shellcheck shell=bash
```

This prevents SC2148 ("Tips depend on target shell and yours is unknown").

## Subshells vs Functions

Inside a subshell `( ... )`, use `exit` to terminate early. `return` only works in functions or sourced scripts.

## Sudo Credential Caching

After long interactive prompts, the sudo timestamp may expire (default 15 minutes). Refresh credentials explicitly before long non-interactive phases:

```bash
sudo -v
```

## Subshell PATH Inheritance

`bash -c "..."` is NOT a login shell and does NOT source `~/.profile`. Tools installed via `pipx` to `$HOME/.local/bin` will be missing from PATH unless explicitly added:

```bash
bash -c "
  export PATH=\"\$HOME/.local/bin:\$PATH\"
"
```

## Interactive Phase Ordering

Any installation step with user-facing popups (GNOME extension confirmations, license dialogs) should run as early as possible in the desktop phase, immediately after the user finishes answering interactive questions.

## Multi-select Defaults

For `gum choose --no-limit`, the `--selected` flag accepts a comma-separated list of values that must exactly match the option strings. To default ALL:

```bash
OPTIONS=("A" "B" "C" "D")
SELECTED="A,B,C,D"
gum choose "${OPTIONS[@]}" --no-limit --selected "$SELECTED" ...
```

## Redundant "None" Options in Multi-select

In multi-select with `--no-limit`, a "None" option is redundant. Users can achieve the same by deselecting everything. Remove it.

## CLI Entry Point Self-Sufficiency

CLI entry points must NOT assume environment variables like `$PROJECT_PATH` are pre-set. Auto-detect from the script's own location:

```bash
if [[ -z "${PROJECT_PATH:-}" ]]; then
  export PROJECT_PATH="$(dirname "$(dirname "$(readlink -f "$0")")")"
fi
```

## Keybinding + Extension Ordering

When shell extensions manage keyboard shortcuts, the base keybinding configuration must run FIRST, then the extension installation. Extensions clear or override base shortcuts to avoid conflicts.

## Copy-Paste Bugs in Globs

When adding new cases to a glob-based installer, verify each `source` target matches its check string. A common copy-paste error: the "Web Apps" check accidentally sources the GitHub Desktop installer.

## Dependabot Configuration

Dependabot removed entirely. No automated dependency branches.


## Actionlint Usage

`actionlint` expects file paths or glob patterns, NOT a directory path with trailing slash:

```bash
# GOOD: no arguments — auto-discovers .github/workflows/
./actionlint -color

# GOOD: explicit glob
./actionlint -color .github/workflows/*.yml

# BAD: directory with trailing slash
./actionlint -color .github/workflows/    # Error: "is a directory"

# BAD: non-matching glob
./actionlint -color .github/workflows/*.yaml    # Error if no .yaml files exist
```

## GitHub Issue Forms

Prefer YAML issue forms (`.yml`) over markdown templates (`.md`). YAML forms provide required field validations, structured input types, and consistent issue formatting.


## Separate Cross-Desktop from DE-Specific Provisioning

Not all GUI apps require a specific desktop environment. Browsers (Chrome, Brave), terminal emulators (Ghostty), media players (VLC), IDEs (VS Code), chat apps (Slack, Discord, Element), AI CLIs, web app .desktop entries, and tools like AppImageLauncher all work on any DE that supports X11/Wayland and XDG standards. Only DE-specific tweaks (GNOME extensions, keybindings, dock config, gsettings/dconf calls, GNOME Boxes/Sushi/Tweaks) should be gated behind a `$XDG_CURRENT_DESKTOP` check.

Directory structure:
```
install/
  apps/                    # Always runs: cross-desktop apps, browsers, AI tools
    ai/                    # AI CLIs and GUI tools (no DE requirement)
    optional/              # Third-party .deb downloaders (Slack, Discord, JetBrains, etc.)
    apps.sh                  # Optional app orchestrator
    ai-tools.sh              # AI tool orchestrator
    browsers.sh              # Chrome + Brave install + xdg-settings default
    ghostty.sh               # Terminal emulator (apt install)
    vlc.sh                   # Media player
    vscode.sh                # IDE
    obsidian.sh              # Notes
    localsend.sh             # File transfer
    element.sh               # Matrix chat
    appimagelauncher.sh      # AppImage integration
    web-apps.sh              # .desktop entries for web apps
  desktop/                 # GNOME-only: extensions, keybindings, dock, gsettings
    extensions/            # Wayland scroll factor (mutter dconf)
    provision/gnome/configure/*.sh  # Keybindings, dock, app grid, default terminal
    gnome-*.sh   # GNOME Boxes, Sushi, Tweaks
```

Corollary: interactive preference questions about cross-desktop apps, browsers, and web apps must be asked of ALL users, not gated behind the GNOME check. Only GNOME extensions and Wayland-specific tweaks stay behind the gate.

## Extension and Configuration Timing

When extensions modify system behavior (keybindings, shortcuts, UI elements):

1. **Disable conflicting system extensions FIRST** — before installing replacements
2. **Install and configure new extensions** — copy schemas, compile, set preferences
3. **Resolve conflicts LAST** — clear or modify system settings that would conflict
   with the newly installed extensions. Not before.

If you clear system keybindings before they're even set, the base config script
will just re-set them and the conflict remains.

## Default Dependencies

Anything set as the system default (terminal emulator, browser, etc.) must be
**always installed**, not optional. If the default points to a missing binary,
core system functionality breaks. Optional apps are extras the user can skip.

## Logging and Error Handling

Always use leveled logging functions. Raw `echo` is acceptable for trivial output but
structured logging makes troubleshooting much easier:

```bash
log_info()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ') INFO] $*"; }
log_warn()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ') WARN] $*" >&2; }
log_error() { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ') ERROR] $*" >&2; }
```

- ISO-8601 UTC timestamps are unambiguous across timezones
- WARN and ERROR go to stderr so they surface even when stdout is piped
- ERR trap should show: failed script, line number, failed command, exit code, and stack trace via `caller` builtin


