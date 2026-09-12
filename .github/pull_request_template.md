## Description

Briefly describe what this PR changes and why.

## Type of change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Code style cleanup

## Review Checklist

Reviewer must verify against `.agent/skills/code-review-checklist/SKILL.md`. Minimum requirements:

- [ ] All shell scripts pass `bash -n` syntax check
- [ ] ShellCheck passes (or warnings are justified)
- [ ] Comments are sentence case with proper punctuation, lazy senior engineer style
- [ ] No references to forbidden project names anywhere
- [ ] No `sudo` added to commands that do not require it
- [ ] No `sudo` removed from commands that genuinely need it
- [ ] Newly provisioned components have corresponding revert scripts
- [ ] GNOME extension schemas are validated, compiled system-wide, and preserve a native fallback until verified
- [ ] Homebrew-installed tools have `brew uninstall` in their revert scripts
- [ ] Downloads and `cd` operations are failure-protected (mktemp -d, retries)
- [ ] Interactive choices use the shared terminal-application protocol
- [ ] Directory = context, filenames do not repeat action prefixes
- [ ] Tested on Ubuntu 26.04 LTS (or equivalent)

## Testing

How did you test? Describe the environment and what you verified.
