#!/bin/bash
# Install Homebrew package manager for Linux.
# Non-interactive via NONINTERACTIVE=1 env var (official Homebrew-supported method).
# May install to /home/linuxbrew/.linuxbrew or $HOME/.linuxbrew depending on sudo access.
if ! command -v brew >/dev/null 2>&1; then
  echo "==> installing homebrew..."
  if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL --retry 3 --retry-delay 5 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    echo "homebrew installed successfully"
    # Add brew to PATH for current session. Check both possible install locations.
    if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
    elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
      eval "$("$HOME/.linuxbrew/bin/brew" shellenv bash)"
    fi
  else
    echo "homebrew install failed (continuing)"
  fi
else
  echo "homebrew already installed, skipping"
fi
