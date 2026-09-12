# Project Architecture and Contracts

Use this skill when changing installer flow, provisioning boundaries, GNOME
behavior, or revert coverage.

## Design Contracts

- Keep the result close to stock Ubuntu and avoid unrequested visual changes.
- Make user choices explicit; do not silently install optional components.
- Pair provisioned components with safe uninstall or reset behavior.
- Keep setup changes understandable from the responsible module.
- Prefer small, single-purpose modules over broad orchestration files.

## Source Layout and Module Boundaries

- Keep all application source under the root `src/` directory. Rust terminal
  modules live beside the existing Bash source trees; do not create a second
  Rust-only source root.
- Keep `bin/justbuntu` as the stable shell launcher. The Cargo package and
  compiled terminal application are both named `justbuntu`; the installed
  binary lives in the private runtime directory and is invoked through the
  shared interactive facade.
- Keep `src/commands/`, `src/core/`, `src/lib/`, `src/provision/`,
  `src/revert/`, `src/config/`, `src/migrate/`, and `src/shell/` aligned with
  their existing responsibilities. Do not put shell commands under
  `src/bin/`, which Cargo reserves for additional Rust binaries.
- Users must not need Rust installed. Development and CI may build the Rust
  application, while installation consumes a release binary verified against
  its published SHA-256 checksum.

- Keep `install.sh` as wiring for validation, preferences, logging, and phases.
- Keep shared infrastructure in `src/lib/` and orchestration in `src/core/`.
- Keep software installation separate from system configuration under
  `src/provision/`.
- Keep cleanup and settings restoration under `src/revert/`.
- Keep shell interaction behind `src/lib/interactive.sh`; shell modules must
  not call a terminal UI dependency directly.
- Resolve paths from the project root, home directory, or the sourced file's
  own location. Never depend on the caller's working directory.
- Keep sourced modules safe to run more than once where practical.

## Logging and reporting boundaries

- Keep logging and failure-report transport in `src/lib/`; installer phases only
  provide context and call the shared helpers.
- Keep the public library facades stable while placing implementation in
  focused `logging/`, `errors/`, and `reporting/` modules. Do not merge these
  responsibilities back into one broad library file.
- Keep session lifecycle, execution boundaries, error context, terminal
  recovery, local report creation, and network transport separate. Traps are a
  last-resort safety net; explicit phase wrappers remain responsible for
  identifying the failed script.
- Logs and generated reports belong in the user-owned XDG state directory,
  with private directory/file permissions and redaction before persistence.
- Issue submission is available only from the failure menu, is opt-in, and
  must be automatic after the user supplies a masked credential. Submit
  directly through the API; do not open a browser or invoke `gh`, and never
  persist the credential. The API requires a compatible token, so keep a
  rejected or unsupported credential local and explain why.
- Git identity (`user.name` and `user.email`) is separate from optional Git
  HTTPS credentials. If credentials are requested, collect a Git username and
  password or PAT/token for Git. Use the existing Git configuration module and
  its credential helper; never run a CLI login flow.

## GNOME Flow

- Gate GNOME-specific commands behind a GNOME environment check.
- Disable conflicting Ubuntu-provided extensions in a dedicated configuration
  module before installing replacement extensions.
- Run the replacement-extension installer once, during the interactive phase.
- Apply extension schemas, preferences, and conflict resolution immediately
  after the replacement extensions are installed, before unrelated install or
  desktop phases begin.
- Validate schemas from each configured extension, install only those schema
  files into the compiled system schema directory, and use ordinary
  `gsettings` after compilation.
- Revert only schema files that are not package-owned, then recompile the
  system schema directory.
- Keep fixed native GNOME `Super+1` through `Super+9` workspace bindings as a
  core feature. Extensions may add behavior around them, but must not replace
  or clear those native bindings.
- Do not let a later directory loop re-run an installer that already ran in an
  earlier phase.

## Revert Boundary

Revert scripts may remove provisioned software and reset its settings. They
must not remove the JustBuntu core, command entry point, shell integration, or
other state required to run JustBuntu again.
