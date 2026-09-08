#!/bin/bash
if [[ "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" != *"Node.js"* ]]; then
  return 0
fi
echo "==> Installing nvm and Node.js..."
# shellcheck disable=SC2016
NVM_INSTALL_CMD='curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash && . "$HOME/.nvm/nvm.sh" && nvm install 24'
if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
  sudo -u "$SUDO_USER" bash -c "$NVM_INSTALL_CMD"
else
  bash -c "$NVM_INSTALL_CMD"
fi
