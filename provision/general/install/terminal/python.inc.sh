#!/bin/bash
if [[ "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" != *"Python"* ]]; then
  return 0
fi
echo "==> Installing Python..."
sudo apt-get install -y python3 python3-pip python3-venv python3-dev python3-full
echo "==> Installing uv..."
if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
  sudo -u "$SUDO_USER" sh -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
else
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
