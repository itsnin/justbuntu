#!/bin/bash
if [[ "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" != *"Web Tools"* ]]; then
  return 0
fi
echo "==> Installing web tools..."
sudo apt-get install -y tidy html-xml-utils sassc
