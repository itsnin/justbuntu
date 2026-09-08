#!/bin/bash
if [[ "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" != *"Go"* ]]; then
  return 0
fi
echo "==> Installing Go..."
sudo apt-get install -y golang
