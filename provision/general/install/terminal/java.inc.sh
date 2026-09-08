#!/bin/bash
if [[ "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" != *"Java"* ]]; then
  return 0
fi
echo "==> Installing Java and Maven..."
sudo apt-get install -y default-jdk maven
