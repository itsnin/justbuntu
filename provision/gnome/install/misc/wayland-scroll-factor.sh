#!/bin/bash
# Install the Ubuntu/Debian amd64 package for wayland-scroll-factor.
WSF_VERSION="1.0.0"
WSF_ASSET="wayland-scroll-factor_1.0.0-1_amd64.deb"
WSF_SHA256="208994120f93f1ff96536e15cee4f5630d7d2c86e94d4bf4a90e1575b929b8d4"
WSF_URL="https://github.com/daniel-g-carrasco/wayland-scroll-factor/releases/download/v$WSF_VERSION/$WSF_ASSET"

# Uses mktemp -d to avoid /tmp races and verifies the release before apt sees it.
(
  set -euo pipefail
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf -- "$TMP_DIR"' EXIT
  cd "$TMP_DIR" || exit 1
  if ! curl -fsSL --retry 2 "$WSF_URL" -o "$WSF_ASSET"; then
    echo "wayland-scroll-factor download failed (continuing)"
    exit 0
  fi
  if ! printf '%s  %s\n' "$WSF_SHA256" "$WSF_ASSET" | sha256sum --check --status -; then
    echo "error: wayland-scroll-factor checksum verification failed" >&2
    exit 1
  fi
  sudo apt-get install -y "./$WSF_ASSET" || echo "wayland-scroll-factor install failed (continuing)"
)
