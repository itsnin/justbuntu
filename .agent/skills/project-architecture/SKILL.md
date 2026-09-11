# Project Architecture and Contracts

Use this skill when changing installer flow, provisioning boundaries, GNOME
behavior, or revert coverage.

## Design Contracts

- Keep the result close to stock Ubuntu and avoid unrequested visual changes.
- Make user choices explicit; do not silently install optional components.
- Pair provisioned components with safe uninstall or reset behavior.
- Keep setup changes understandable from the responsible module.
- Prefer small, single-purpose modules over broad orchestration files.

## Module Boundaries

- Keep `install.sh` as wiring for validation, preferences, logging, and phases.
- Keep shared infrastructure in `lib/` and orchestration in `core/`.
- Keep software installation separate from system configuration under
  `provision/`.
- Keep cleanup and settings restoration under `revert/`.
- Resolve paths from the project root, home directory, or the sourced file's
  own location. Never depend on the caller's working directory.
- Keep sourced modules safe to run more than once where practical.

## Logging and reporting boundaries

- Keep logging and failure-report transport in `lib/`; installer phases only
  provide context and call the shared helpers.
- Logs and generated reports belong in the user-owned XDG state directory,
  with private directory/file permissions and redaction before persistence.
- Issue submission is opt-in and must be automatic after the user supplies a
  masked personal access token. Do not open a browser, invoke `gh`, collect an
  account password, or persist the token. If submission cannot authenticate,
  keep the redacted report locally.
- Git identity (`user.name` and `user.email`) is separate from GitHub API
  authentication. A fallback local username is only an identity default; it
  is never treated as authorization.

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
