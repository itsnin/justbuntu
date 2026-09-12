#!/bin/bash
# Validate the system meets JustBuntu requirements.
# Uses /etc/os-release (freedesktop standard) with lsb_release fallback.
# Pure bash arithmetic for version comparison — no external deps needed.

# Primary method: /etc/os-release (standard on all modern systemd distros)
if [ -f "/etc/os-release" ]; then
  . /etc/os-release
elif command -v lsb_release >/dev/null 2>&1; then
  # Fallback for older systems without /etc/os-release
  ID=$(lsb_release -si 2>/dev/null | tr '[:upper:]' '[:lower:]')
  VERSION_ID=$(lsb_release -sr 2>/dev/null)
elif command -v hostnamectl >/dev/null 2>&1; then
  # Second fallback: hostnamectl
  ID=$(hostnamectl 2>/dev/null | awk -F': ' '/Operating System:/ {print tolower($2)}' | awk '{print $1}')
  VERSION_ID=$(hostnamectl 2>/dev/null | awk -F': ' '/Operating System:/ {print $2}' | grep -oE '[0-9]+\.[0-9]+' | head -1)
else
  echo "$(tput setaf 1)Error: Unable to determine OS."
  echo "Neither /etc/os-release, lsb_release, nor hostnamectl are available."
  echo "Installation stopped."
  exit 1
fi

# Validate VERSION_ID is numeric before doing arithmetic
if ! [[ "$VERSION_ID" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  echo "$(tput setaf 1)Error: Could not parse OS version: '$VERSION_ID'"
  echo "Installation stopped."
  exit 1
fi

# Check Ubuntu 26.04+ requirement. Pure bash integer comparison on major version.
VERSION_MAJOR=${VERSION_ID%%.*}
if [ "$ID" != "ubuntu" ] || [ "$VERSION_MAJOR" -lt 26 ]; then
  echo "$(tput setaf 1)Error: OS requirement not met"
  echo "You are currently running: $ID $VERSION_ID"
  echo "OS required: Ubuntu 26.04 LTS or newer"
  echo "JustBuntu does not support versions below 26.04."
  echo "Installation stopped."
  exit 1
fi

# x86_64 only. ARM, RISC-V, etc. not supported.
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
  echo "$(tput setaf 1)Error: Unsupported architecture detected"
  echo "Current architecture: $ARCH"
  echo "This installation is only supported on x86_64."
  echo "Installation stopped."
  exit 1
fi
