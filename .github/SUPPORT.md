## Getting help with JustBuntu

If JustBuntu is not working as expected, check these first:

- Read the README for installation and usage instructions
- Check the issues tab for existing reports of the same problem

## Reporting a bug

Open a bug report issue using the bug report template. It asks for the information needed to reproduce and fix the problem, including Ubuntu version, architecture, and relevant log output.

When the installer offers to submit a redacted failure report, submission is
optional. If you choose submission, enter a GitHub credential in the masked
prompt. The installer sends it directly through the API without
using `gh` or opening a browser. GitHub's REST documentation lists
`Issues: write` for fine-grained create-issue tokens, but public-repository
access can accept a token with less permission; the installer lets GitHub
decide and explains a rejection. A normal account password is not an API
credential, so GitHub may reject it. If you decline or do not provide a
credential, the report remains in `~/.local/state/justbuntu/reports/`. Include
the displayed error ID and attach that redacted report when asking for help.

## Requesting a feature

Open a feature request issue using the feature request template.

## Security issues

Do not open a public issue for a security vulnerability. See [SECURITY.md](../SECURITY.md) for the private reporting process.
