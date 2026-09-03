#!/bin/bash
AVAILABLE_LANGUAGES=("Python" "Rust" "Go" "Node.js" "Java" "C/C++ Build Tools" "PostgreSQL" "Web Tools")

# Use pre-selected languages from first run if available, otherwise prompt.
if [ -n "${JUSTBUNTU_FIRST_RUN_LANGUAGES:-}" ]; then
  SELECTED="$JUSTBUNTU_FIRST_RUN_LANGUAGES"
else
  SELECTED_LANGUAGES="Python,Node.js"
  SELECTED=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 12 --header "Select development tools")
fi

# Common development libraries. Always installed for any language.
sudo apt-get install -y \
  libssl-dev libffi-dev zlib1g-dev libbz2-dev liblzma-dev libreadline-dev libncurses-dev \
  ca-certificates gnupg

if [[ "$SELECTED" == *"Python"* ]]; then
  echo "==> Installing Python..."
  sudo apt-get install -y python3 python3-pip python3-venv python3-dev python3-full
  echo "==> Installing uv..."
  if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
    sudo -u "$SUDO_USER" sh -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
  else
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
fi

if [[ "$SELECTED" == *"Rust"* ]]; then
  echo "==> Installing rustup..."
  if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
    sudo -u "$SUDO_USER" sh -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
fi

if [[ "$SELECTED" == *"Go"* ]]; then
  echo "==> Installing Go..."
  sudo apt-get install -y golang
fi
if [[ "$SELECTED" == *"Node.js"* ]]; then
  echo "==> Installing nvm and Node.js..."
  NVM_INSTALL_CMD='curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash && \. "$HOME/.nvm/nvm.sh" && nvm install 24'
  if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
    sudo -u "$SUDO_USER" bash -c "$NVM_INSTALL_CMD"
  else
    bash -c "$NVM_INSTALL_CMD"
  fi
fi

if [[ "$SELECTED" == *"Java"* ]]; then
  echo "==> Installing Java and Maven..."
  sudo apt-get install -y default-jdk maven
fi

if [[ "$SELECTED" == *"C/C++ Build Tools"* ]]; then
  echo "==> Installing C/C++ build tools..."
  sudo apt-get install -y build-essential gcc g++ clang clangd clang-format clang-tidy make cmake ninja-build gdb pkg-config valgrind llvm
fi

if [[ "$SELECTED" == *"PostgreSQL"* ]]; then
  echo "==> Installing PostgreSQL..."
  sudo apt-get install -y postgresql
fi

if [[ "$SELECTED" == *"Web Tools"* ]]; then
  echo "==> Installing web tools..."
  sudo apt-get install -y tidy html-xml-utils sassc
fi
