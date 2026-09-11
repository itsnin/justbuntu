# Logging and Observability

## Log Levels

Standard severity levels: DEBUG, INFO, WARN, ERROR.

## Runtime contract

- Use the shared functions in `lib/logging.sh`; do not create another logger
  in a provisioning script.
- Keep the terminal output useful while mirroring a redacted copy to the
  user-owned state file at `${XDG_STATE_HOME:-$HOME/.local/state}/justbuntu/install.log`.
- Create the state directory with mode `0700` and the log with mode `0600`.
- Treat command output as untrusted text. Redact credentials before writing,
  displaying, or including it in a report.
- Record phase and script boundaries with `run_script`; failure context should
  identify the phase, script, command, and exit status without exposing input.
- Use `mktemp` for failure reports and temporary request material. Temporary
  credential/request files must be mode `0600` and removed after use.

## Failure reports and issue submission

- `lib/reporting.sh` creates a local redacted report before offering any
  network action. A report is stored under the private `justbuntu/reports`
  directory.
- Public issue submission is an explicit user choice. The optional GitHub
  personal access token is entered once in a masked setup prompt, kept only in
  memory for that run, and used by `curl` after the user selects submission;
  the flow must not invoke `gh`, open a browser, collect an account password,
  or store the token in Git configuration.
- A missing token, missing dependency, cancellation, or failed request must
  leave the report locally and explain the reason. Never offer anonymous or
  generic-identity submission as if it were authenticated.
- Do not use the installer’s public issue flow for security vulnerabilities;
  keep security disclosures on the private channel in `SECURITY.md`.

## What NOT to Log

- Secrets, passwords, API keys — redact or mask
- Personal data — emails, names, phone numbers
- Large binary output — log a summary instead
