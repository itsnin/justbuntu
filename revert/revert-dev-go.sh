#!/bin/bash
# uninstall go programming language
sudo apt-get purge -y golang golang-*
sudo apt-get autoremove -y --purge
# remove go workspace if it exists
rm -rf "$HOME/go"
