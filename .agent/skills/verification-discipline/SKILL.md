# Verification Discipline

Use evidence appropriate to the claim and the risk of the change.

## Before Coding

- Read the relevant implementation and its callers.
- Search for the same bug pattern elsewhere in the repository.
- State assumptions when they affect scope or behavior.
- Prefer a small reproduction or focused test for a bug fix.

## During Coding

- Keep every changed line traceable to the request or the verified fix.
- Check authoritative documentation when behavior is version-sensitive or
  externally defined.
- Treat search results, existing comments, and assumptions as hypotheses until
  the underlying source or code confirms them.

## Before Reporting

Label factual claims as one of:

- `Verified via [tool or source] just now`
- `From training data (may be outdated or wrong)`
- `Not verified — please confirm independently`

Use real source URLs only. Re-read the source before presenting a claim as
verified, and mention plausible uncertainty instead of smoothing it over.

## Verification Scope

Run the smallest relevant checks first. For modified Bash, run `bash -n`; for
installer-flow changes, test the affected order and failure path. Use a clean
VM or container for release-level installer changes, not as a mandatory step
for every local edit.
- For extension GSettings schemas, verify XML validation, system compilation,
  schema resolution, and the read-back value before removing a working native
  fallback.
