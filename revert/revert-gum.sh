#!/bin/bash
sudo apt purge -y gum
sudo rm -f /etc/apt/sources.list.d/charm.list
sudo rm -f /etc/apt/keyrings/charm.gpg
sudo apt update
