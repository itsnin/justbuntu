#!/bin/bash
# Gum is used for the JustBuntu commands for tailoring JustBuntu after the initial install.
(
  cd /tmp || exit 1
  GUM_VERSION="0.17.0"
  if wget -qO gum.deb "https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_amd64.deb"; then
    sudo apt-get install -y --allow-downgrades ./gum.deb || echo "gum install failed"
    rm -f gum.deb
  else
    echo "gum download failed"
    exit 1
  fi
)
