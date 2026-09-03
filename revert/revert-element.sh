#!/bin/bash
# Uninstall Element desktop Matrix client
sudo apt purge -y element-desktop
sudo rm -f /usr/share/keyrings/element-io-archive-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/element-io.list
sudo apt update
sudo apt autoremove -y --purge
