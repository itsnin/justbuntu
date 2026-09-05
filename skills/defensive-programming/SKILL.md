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
