#!/bin/bash
if [[ "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" != *"Rust"* ]]; then
  return 0
fi
echo "==> Installing rustup..."
if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
  sudo -u "$SUDO_USER" sh -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
else
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
