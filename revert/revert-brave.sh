#!/bin/bash
sudo apt purge -y brave-origin brave-browser
sudo rm -f /usr/share/keyrings/brave-browser-archive-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/brave-browser-release.list
sudo rm -f /etc/apt/sources.list.d/brave-browser-release.sources
sudo apt update
