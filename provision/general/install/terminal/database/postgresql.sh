#!/bin/bash
if [[ "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" != *"PostgreSQL"* ]]; then
  return 0
fi
echo "==> Installing PostgreSQL..."
sudo apt-get install -y postgresql
