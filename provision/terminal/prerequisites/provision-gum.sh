#!/bin/bash
# Install gum via Charm's official apt repository.
# This gives us the latest version automatically via apt.
if ! command -v gum >/dev/null 2>&1; then
  echo "==> installing gum..."
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
  sudo apt update
  if ! sudo apt install -y gum; then
    echo "ERROR: gum installation failed. Gum is a required dependency for JustBuntu." >&2
    echo "Please check your network connection and apt sources, then re-run." >&2
    exit 1
  fi
else
  echo "gum already installed, skipping"
fi
