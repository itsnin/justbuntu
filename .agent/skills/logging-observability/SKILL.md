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
- Public issue submission is an explicit user choice. Only after that choice,
  request a GitHub credential in a masked prompt, keep it in memory for one
  request, and unset it afterward; the flow must not invoke `gh`, open a
  browser, or store the credential in Git configuration. Do not locally reject
  a credential based on a permission label; submit it to the public repository
  endpoint and explain GitHub's response.
  GitHub's formal fine-grained-token documentation lists `Issues: write` for
  creating issues, while public-repository access can have broader behavior.
- A missing token, missing dependency, cancellation, or failed request must
  leave the report locally and explain the reason. Never offer anonymous or
  generic-identity submission as if it were authenticated.
- Do not use the installer’s public issue flow for security vulnerabilities;
  keep security disclosures on the private channel in `SECURITY.md`.

## What NOT to Log

- Secrets, passwords, API keys — redact or mask
- Personal data — emails, names, phone numbers
- Large binary output — log a summary instead
