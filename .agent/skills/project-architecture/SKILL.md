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

## GNOME Flow

- Gate GNOME-specific commands behind a GNOME environment check.
- Disable conflicting Ubuntu-provided extensions in a dedicated configuration
  module before installing replacement extensions.
- Run the replacement-extension installer once, during the interactive phase.
- Apply extension schemas, preferences, and conflict resolution only after the
  corresponding extension has been installed.
- Compile and use each extension's schemas from its own extension
  directory; do not copy user-installed extension schemas into the system
  schema directory.
- Keep native GNOME shortcuts as a fallback until extension settings are
  verified and the replacement extension is enabled.
- Do not let a later directory loop re-run an installer that already ran in an
  earlier phase.

## Revert Boundary

Revert scripts may remove provisioned software and reset its settings. They
must not remove the JustBuntu core, command entry point, shell integration, or
other state required to run JustBuntu again.
