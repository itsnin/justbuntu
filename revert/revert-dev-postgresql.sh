#!/bin/bash
# uninstall postgresql server
sudo apt-get purge -y postgresql postgresql-*
sudo apt-get autoremove -y --purge
# remove postgres user and data directory
sudo rm -rf /var/lib/postgresql /etc/postgresql
sudo userdel -r postgres 2>/dev/null || true
