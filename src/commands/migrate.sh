#!/bin/bash
# Run pending JustBuntu migrations. Each migration is a numbered script in
# the migrate/ directory. Applied migrations are tracked in a state file.
STATE_DIR="$HOME/.local/share/justbuntu/state"
STATE_FILE="$STATE_DIR/migrate-version"
MIGRATE_DIR="$JUSTBUNTU_PATH/migrate"

mkdir -p "$STATE_DIR"

# Determine current version
if [ -f "$STATE_FILE" ]; then
  CURRENT_VERSION=$(cat "$STATE_FILE")
else
  CURRENT_VERSION=0
fi

echo "Current migration version: $CURRENT_VERSION"

# Find and sort migration scripts
shopt -s nullglob
migrations=("$MIGRATE_DIR"/[0-9][0-9][0-9][0-9]-*.sh)
shopt -u nullglob

if [ ${#migrations[@]} -eq 0 ]; then
  echo "No migrations found."
  exit 0
fi

applied=0
for script in "${migrations[@]}"; do
  filename=$(basename "$script")
  version=${filename%%-*}
  version_num=$((10#$version))  # force decimal, strip leading zeros

  if [ "$version_num" -le "$CURRENT_VERSION" ]; then
    continue
  fi

  echo "Applying: $filename"
  if source "$script"; then
    echo "$version_num" > "$STATE_FILE"
    CURRENT_VERSION=$version_num
    applied=$((applied + 1))
  else
    echo "Migration failed: $filename"
    echo "Stopped at version $CURRENT_VERSION"
    exit 1
  fi
done

echo "Applied $applied migration(s). Current version: $CURRENT_VERSION"
