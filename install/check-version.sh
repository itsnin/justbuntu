#!/bin/bash
if [ ! -f /etc/os-release ]; then
  echo "$(tput setaf 1)Error: Unable to determine OS. /etc/os-release file not found."
  echo "Installation stopped."
  exit 1
fi
. /etc/os-release
# check if running on Ubuntu 26.04 or higher
if [ "$ID" != "ubuntu" ] || [ $(echo "$VERSION_ID >= 26.04" | bc) != 1 ]; then
  echo "$(tput setaf 1)Error: OS requirement not met"
  echo "You are currently running: $ID $VERSION_ID"
  echo "OS required: Ubuntu 26.04 LTS or newer"
  echo "JustBuntu does not support versions below 26.04."
  echo "Installation stopped."
  exit 1
fi
# check if running on x86
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "i686" ]; then
  echo "$(tput setaf 1)Error: Unsupported architecture detected"
  echo "Current architecture: $ARCH"
  echo "This installation is only supported on x86 architectures (x86_64 or i686)."
  echo "Installation stopped."
  exit 1
fi
