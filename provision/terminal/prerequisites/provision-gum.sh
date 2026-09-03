#!/bin/bash
# Install gum via Charm's official apt repository.
# This gives us the latest version automatically via apt.
if ! command -v gum >/dev/null 2>&1; then
  echo "==> installing gum..."
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
  sudo apt update
  sudo apt install -y gum || echo "gum install failed"
else
  echo "gum already installed, skipping"
fi
