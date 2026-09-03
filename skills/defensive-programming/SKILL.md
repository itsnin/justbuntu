# Defensive Programming

## Overview

Write scripts that anticipate failure, validate assumptions, and degrade gracefully.

**Confidence**: Verified via LobeHub defensive patterns, bash-style-guide repo, and coding-style-guide repo just now.

## Core Defensive Principles

1. **Treat all input as untrusted** — arguments, environment variables, file contents, command output
2. **Validate early, fail clearly** — check preconditions before doing work
3. **Design for idempotency** — safe to run multiple times
4. **Support dry-run mode** — show what would change without changing anything
5. **Clean up after yourself** — use `mktemp` + `trap` for temp files
6. **Check dependencies exist** — verify required commands before using them

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

# Validate against allowlist (safer than blocklist)
case "$action" in
    install|remove|update) ;;
    *) echo "error: invalid action: $action" >&2; exit 1 ;;
esac
```

## Dependency Checking

```bash
# Use command -v, NOT which
if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required but not installed" >&2
    exit 1
fi
```

## Safe Temporary Files

```bash
# Create temp directory with automatic cleanup
TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT ERR INT TERM

# Or for a single file
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT
```

**Self-challenge**: Never use predictable temp paths like `/tmp/script.tmp`. They are race-condition vulnerabilities and can be symlinked to overwrite important files.

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

run_cmd sudo apt install -y btop
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

Desktop-launched applications inherit their environment from the systemd user session, NOT from .bashrc. Commands that rely on PATH entries set in shell config files will fail with "command not found" or "exec: AccessDenied." Always use absolute paths in .desktop Exec= lines.

Bad: Exec=justbuntu
Good: Exec=/home/user/.local/share/justbuntu/bin/justbuntu

## Network Install Commands Need Robustness

When piping curl into bash for third-party installers, always add retry logic and graceful failure:

```bash
if curl -fsSL --retry 3 --retry-delay 5 https://example.com/install.sh | bash; then
  echo "installed"
else
  echo "install failed (continuing)"
fi
```

For high-traffic endpoints that may be down (e.g., opencode.ai), add a fallback installation method such as direct binary download from GitHub releases.

## GitHub Release Downloads — MANDATORY PATTERN

For ANY package fetched from GitHub releases, ALWAYS query the last 10 releases and iterate to find a matching asset. The "latest" release is frequently broken, missing assets, or a prerelease. This pattern is not optional:

**Rule**: Every GitHub release download MUST use the last-10-releases fallback pattern.

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
Skip prereleases. Gracefully handle "no asset found" by returning early.

## Executable Bits and Git

CLI entry points MUST have the executable bit set AND tracked in git:
```bash
chmod +x bin/script
git add bin/script        # git tracks mode 100755 vs 100644
git ls-files --stage bin/script   # verify: 100755 = executable
```
**Rule**: Never assume a clone preserves permissions without verifying git mode. Add defense-in-depth `chmod +x` in provisioning scripts.

## Desktop Entries (.desktop files)

After creating or modifying `.desktop` files in `~/.local/share/applications/`, ALWAYS refresh the desktop database:
```bash
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
```
Without this, GNOME may silently ignore new entries until the next login.

For icon paths, probe for multiple possible filenames since naming varies between versions:
```bash
for icon_name in "toolbox.svg" "jetbrains-toolbox.svg" "icon.svg"; do
  [ -f "$path/$icon_name" ] && TOOLBOX_ICON="$path/$icon_name" && break
done
```

## Web App Icons

Google's S2 favicon service returns generic icons for Google's own products (Drive, Keep show generic G). Always try direct favicon first:
```bash
# primary: direct from the host (correct product icons)
curl -sL -o icon.png "https://${DOMAIN}/favicon.ico"
# fallback: Google S2 service
curl -sL -o icon.png "https://www.google.com/s2/favicons?sz=128&domain=${DOMAIN}"
```

## JetBrains Product Downloads

**CRITICAL VERIFIED FACT**: JetBrains Toolbox tarball structure is:
```
jetbrains-toolbox-<version>/
  bin/
    jetbrains-toolbox    ← binary is INSIDE bin/ subdirectory
    toolbox.svg          ← icon is INSIDE bin/ subdirectory
    jetbrains-toolbox.desktop
    lib/
    jre/
```
Use `mv "$TOOLBOX_DIR"/bin/* target/` NOT `mv "$TOOLBOX_DIR"/* target/`.

Never hardcode download URLs. Use official public API:
```bash
TOOLBOX_URL=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data['TBA'][0]['downloads']['linux']['link'])
")
```
Product codes: TBA=Toolbox App, IIU=IntelliJ Ultimate, PCP=PyCharm Professional, etc.

**Official behavior**: Toolbox creates its own `.desktop` file on first launch at `~/.local/share/applications/`.

## Web App Icons — Curated CDN Pattern

Google's S2 favicon service returns GENERIC icons for Google products (Drive shows a G, not the Drive logo). Use the **homarr-labs/dashboard-icons** CDN (1800+ curated icons) for known apps:
```bash
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
Fallback: direct `/favicon.ico` → Google S2 service.

## Subshells vs Functions

Inside a subshell `( ... )`, use `exit` to terminate early. `return` only works in functions or sourced scripts. This is a common bash pitfall.

## CLI Executable Bits in Git

Always verify CLI entry points have mode `100755` in git:
```bash
git ls-files --stage bin/scriptname   # 100755 = executable, 100644 = not
chmod +x bin/scriptname
git add bin/scriptname
```
Add defense-in-depth `chmod +x` in provisioning scripts.

## Sudo Credential Caching

After long interactive prompts, the sudo timestamp may expire (default 15 min).
Refresh credentials explicitly before long non-interactive phases:
```bash
sudo -v   # extends sudo cache for another 15 min from this point
```

## Subshell PATH Inheritance

`bash -c "..."` is NOT a login shell and does NOT source `~/.profile`.
Tools installed via `pipx` (to `$HOME/.local/bin`) or other user-local paths
will be MISSING from PATH unless explicitly added:
```bash
bash -c "
  export PATH="\$HOME/.local/bin:\$PATH"
  # now gext and other pipx tools work
"
```

## Interactive Phase Ordering

Any installation step with user-facing popups (GNOME extension confirmations,
license dialogs, etc.) should run as early as possible in the desktop phase,
immediately after the user finishes answering interactive questions. The user
is already at the keyboard and paying attention.

## Multi-select Defaults

For `gum choose --no-limit`, the `--selected` flag accepts a comma-separated
list of values that must exactly match the option strings. To default ALL:
```bash
OPTIONS=("A" "B" "C" "D")
SELECTED="A,B,C,D"
gum choose "${OPTIONS[@]}" --no-limit --selected "$SELECTED" ...
```

## Redundant "None" Options in Multi-select

In multi-select with `--no-limit`, a "None" option is redundant — users can
achieve the same by deselecting everything. Remove it. The empty-string case
should still be handled explicitly.
