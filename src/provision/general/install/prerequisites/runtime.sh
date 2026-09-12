#!/bin/bash
# Install the verified JustBuntu terminal application used by shell modules.

if [[ -x "${JUSTBUNTU_APP_BIN:-}" ]]; then
  return 0
fi

JUSTBUNTU_ROOT="${JUSTBUNTU_ROOT:-$HOME/.local/share/justbuntu}"
JUSTBUNTU_APP_BIN="${JUSTBUNTU_APP_BIN:-$JUSTBUNTU_ROOT/libexec/justbuntu}"
RELEASE_BASE_URL="${JUSTBUNTU_RELEASE_BASE_URL:-https://github.com/itsnin/justbuntu/releases/latest/download}"
TMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TMP_DIR"' RETURN

mkdir -p -- "$(dirname -- "$JUSTBUNTU_APP_BIN")"
curl --fail --silent --show-error --location \
  "$RELEASE_BASE_URL/justbuntu" -o "$TMP_DIR/justbuntu"
curl --fail --silent --show-error --location \
  "$RELEASE_BASE_URL/justbuntu.sha256" -o "$TMP_DIR/justbuntu.sha256"

EXPECTED_SHA=$(awk '$2 == "justbuntu" || $2 == "*justbuntu" { print $1; exit }' \
  "$TMP_DIR/justbuntu.sha256")
if [[ ! "$EXPECTED_SHA" =~ ^[[:xdigit:]]{64}$ ]]; then
  echo "error: release checksum is missing or malformed" >&2
  return 1
fi

ACTUAL_SHA=$(sha256sum -- "$TMP_DIR/justbuntu" | awk '{print $1}')
if [[ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]]; then
  echo "error: JustBuntu release checksum verification failed" >&2
  return 1
fi

install -m 0755 -- "$TMP_DIR/justbuntu" "$JUSTBUNTU_APP_BIN"
export JUSTBUNTU_ROOT JUSTBUNTU_APP_BIN
