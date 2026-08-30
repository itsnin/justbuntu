#!/bin/bash
# uninstall claude desktop
sudo apt-get remove -y claude-desktop 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/claude-desktop.list
sudo rm -f /usr/share/keyrings/claude-desktop-archive-keyring.asc
sudo apt-get update >/dev/null 2>&1 || true
sudo apt-get autoremove -y --purge 2>/dev/null || true
