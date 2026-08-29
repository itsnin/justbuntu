#!/bin/bash
# uninstall java and maven
sudo apt-get purge -y default-jdk maven
sudo apt-get autoremove -y --purge
