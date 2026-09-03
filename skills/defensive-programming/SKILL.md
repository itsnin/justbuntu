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


## Third-Party Apt Repositories

When a project offers an official apt repository, prefer it over hardcoded .deb downloads. It gives automatic updates via `apt upgrade`. Standard pattern:

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.example.com/key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/example.gpg
echo "deb [signed-by=/etc/apt/keyrings/example.gpg] https://repo.example.com/apt/ * *" | sudo tee /etc/apt/sources.list.d/example.list
sudo apt update && sudo apt install package
```

Revert must remove both the `.list` file and the keyring file, then run `apt update`.

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

## GitHub Issue Forms

Prefer YAML issue forms (`.yml`) over markdown templates (`.md`). YAML forms provide required field validations, structured input types, and consistent issue formatting.
