#!/bin/bash
if [ ! -f "/etc/os-release" ]; then
  echo "$(tput setaf 1)Error: Unable to determine OS. /etc/os-release file not found."
  echo "Installation stopped."
  exit 1
fi
. /etc/os-release
# Check if running on Ubuntu 26.04 or higher. Pure bash, no external deps.
VERSION_MAJOR=$(echo "$VERSION_ID" | cut -d. -f1)
if [ "$ID" != "ubuntu" ] || [ "$VERSION_MAJOR" -lt 26 ]; then
  echo "$(tput setaf 1)Error: OS requirement not met"
  echo "You are currently running: $ID $VERSION_ID"
  echo "OS required: Ubuntu 26.04 LTS or newer"
  echo "JustBuntu does not support versions below 26.04."
  echo "Installation stopped."
  exit 1
fi
# Check if running on x86_64 only.
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
  echo "$(tput setaf 1)Error: Unsupported architecture detected"
  echo "Current architecture: $ARCH"
  echo "This installation is only supported on x86_64."
  echo "Installation stopped."
  exit 1
fi
