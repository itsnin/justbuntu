# Release Versioning

Use this skill when creating or changing a public release, tag, or release
automation.

## Public release identifier

- Use the exact format `YYYY.MM.PATCH`, with no `v` prefix.
- `YYYY` is the calendar year and `MM` is the calendar month of the release.
- `PATCH` is the release sequence within that monthly release line. It is not
  a calendar field and may be `01`, `02`, `12`, `99`, `100`, or another
  positive decimal value.
- Start the patch sequence at `01` for a new calendar month and increment it
  for each subsequent release in that month.
- Keep the root `version` file, the Git tag, and the GitHub release name in
  sync. The tag must point to the commit containing that version value.

## Release workflow

Before publishing a release:

1. Set `version` to the next calendar identifier.
2. Run the repository's local CI-equivalent checks.
3. Commit and push the version change.
4. Create the matching tag from that commit and push the tag.
5. Verify the GitHub workflow completed and the published assets match their
   checksums.

Do not use Semantic Versioning, a `v` prefix, automatic semver resolution, or
an unrelated release number for public JustBuntu tags. Cargo's package version
is internal build metadata; the root `version` file and matching tag are the
public release source of truth.
