#!/bin/bash
# install homebrew package manager for linux
# installs to /home/linuxbrew/.linuxbrew by default
# non-interactive: the install script pauses for confirmation, so we pipe "ENTER"
if ! command -v brew >/dev/null 2>&1; then
  echo "==> installing homebrew..."
  if echo | /bin/bash -c "$(curl -fsSL --retry 3 --retry-delay 5 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    echo "homebrew installed successfully"
    # add brew to PATH for current session so subsequent scripts can use it
    if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
    fi
  else
    echo "homebrew install failed (continuing)"
  fi
else
  echo "homebrew already installed, skipping"
fi
