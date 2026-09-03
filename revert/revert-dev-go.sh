#!/bin/bash
# Uninstall Go programming language
sudo apt-get purge -y golang golang-*
sudo apt-get autoremove -y --purge
# Remove Go workspace if it exists
rm -rf "$HOME/go"
