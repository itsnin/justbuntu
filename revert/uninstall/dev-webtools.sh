#!/bin/bash
# Uninstall web development tools
sudo apt-get purge -y tidy html-xml-utils sassc
sudo apt-get autoremove -y --purge
