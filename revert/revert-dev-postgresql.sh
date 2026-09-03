#!/bin/bash
# Uninstall PostgreSQL server
sudo apt-get purge -y postgresql postgresql-*
sudo apt-get autoremove -y --purge
# Remove postgres user and data directory
sudo rm -rf /var/lib/postgresql /etc/postgresql
sudo userdel -r postgres 2>/dev/null || true
