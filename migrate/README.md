# Migrations

JustBuntu migration framework. Handles config and data transitions between versions.

## Naming

```
0001-short-description.sh
```

- `0001` — sequential 4-digit number, never reused
- `short-description` — kebab-case, what the migration does

## Rules

1. **Idempotent**: Each migration MUST check if it has already been applied.
2. **Immutable**: Once shipped, a migration file is NEVER edited. Fixes go in a new migration.
3. **Version tracking**: The current migration version is stored at
   `$HOME/.local/share/justbuntu/state/migrate-version`.

## Running

```bash
justbuntu migrate
```
