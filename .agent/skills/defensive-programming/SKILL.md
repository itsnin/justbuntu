# Defensive Programming

Keep provisioning predictable, reversible, and safe when external systems or
user input fail.

## Validate Inputs

Validate argument count, file type, numeric ranges, and allowlisted values
before using input in a command. Reject invalid input with a clear message on
stderr.

```bash
if [[ $# -ne 1 || ! -f "$1" ]]; then
  printf 'error: expected one existing file\n' >&2
  exit 2
fi
```

## Check Dependencies

Check required commands before the first use. A dependency required to keep
the workflow safe or interactive must fail clearly; an optional component may
report the failure and continue only when that is an intentional contract.

```bash
if ! command -v required_command >/dev/null 2>&1; then
  printf 'error: required_command is missing\n' >&2
  exit 1
fi
```

## Temporary Files and Directories

Use `mktemp`, never predictable names under `/tmp`. Clean every temporary path
on normal completion and interruption. When a consumer identifies a package
by suffix, use `mktemp --suffix=.deb` or a temporary directory with a stable
filename inside it.

```bash
TMP_DIR=$(mktemp -d)
cleanup() { rm -rf -- "$TMP_DIR"; }
trap cleanup EXIT INT TERM
```

Do not use `mktemp -u`; it only reserves a name and leaves a race before the
file is created.

## Atomic File Changes

Write new content to a temporary file in the destination filesystem, set its
permissions, then rename it into place. Preserve the original file before
changing user-owned configuration, and do not overwrite that backup on later
runs.

## Idempotency

A second run should converge on the same state. Check before installing a
binary, creating a directory, appending a configuration line, or changing a
setting. Avoid broad cleanup globs and make each cleanup target explicit.

## Download and Package Safety

Use TLS-enabled downloads with failure checking and bounded retries. Download
to a temporary path before executing or installing. Prefer a vendor package
repository over a moving direct-download URL. For release assets, validate the
expected format and architecture and verify a published checksum or signature
when available.

Do not pipe unreviewed network content directly into a shell. If an upstream
installer must be used, save it first, preserve its temporary-file cleanup,
and invoke the intended interpreter explicitly.

```bash
if ! curl -fsSL --retry 3 --retry-delay 5 "$URL" -o "$TMP_FILE"; then
  printf 'error: download failed\n' >&2
  exit 1
fi
bash "$TMP_FILE"
```

## Desktop Entries

Use absolute executable and icon paths in `.desktop` files because desktop
launchers do not reliably inherit interactive shell startup files. Refresh the
desktop database after changing entries when the command is available.

## Executable Permissions

Track executable bits for entry points that users invoke directly. Scripts
that are only sourced or passed to `bash` do not need executable permissions.
Check permissions in review instead of adding `chmod` as a substitute for
correct repository state.

## Dotfiles

Never replace a user's shell startup file. Preserve existing content, create a
backup once when appropriate, and append guarded lines so repeated runs do not
duplicate configuration.

## Hard and Optional Failures

Required setup failures must stop before later code runs against an incomplete
environment. Optional component failures need a concise warning and a safe
continuation path. Do not hide a failure with an unconditional `true`.

## Process Boundaries

Variables, traps, and working-directory changes do not cross a new `bash -c`
process. Pass values explicitly and use a deliberate exit status or other
well-scoped signal when a child has handled an error that the parent must not
handle twice.

Inside a subshell, use `exit`; `return` is for functions or sourced files.

## Interactive and TTY Operations

Keep user-facing prompts on a real terminal. Output duplication through a pipe
can buffer terminal control sequences, so temporarily restore the original
terminal descriptors around TUI prompts. Cache privileged credentials while the
terminal is visible, then refresh them after long interactive phases.

When a downloaded installer reads `/dev/tty`, piping input to its standard
input may not answer it. Use an explicit PTY strategy only when the installer
requires it, and keep the input finite and intentional.

## Repository and Apt Trust

Use repository-specific keyrings and scoped `signed-by` configuration for third-
party APT sources. Do not add external keys to a global trust store. Keep
installation and cleanup paths together so a repository, keyring, or generated
configuration file can be removed safely.

## Desktop Environment Boundaries

Gate desktop-environment-specific commands behind a detected environment.
Cross-desktop tools should not depend on GNOME-specific commands. Verify
extension schemas and settings against the installed extension rather than
assuming a version-specific key.

When an extension replaces a built-in behavior, disable the conflicting
behavior before installing the replacement, then apply extension-specific
configuration after installation.

## Binary Installers

Before extracting or moving a downloaded binary, check the destination state.
Use explicit source and destination paths, avoid overwriting unrelated files,
and make the operation safe to repeat.

## Logging

Log enough context to identify the failed component, command, exit status, and
relevant call path. Never log passwords, tokens, API keys, or full personal
data. Preserve the original failure status when cleanup or error reporting
runs.
