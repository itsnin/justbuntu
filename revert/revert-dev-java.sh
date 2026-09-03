#!/bin/bash
# Uninstall Java and Maven
sudo apt-get purge -y default-jdk maven
sudo apt-get autoremove -y --purge
