#!/bin/bash
# uninstall discord
sudo apt purge -y discord 2>/dev/null || true
sudo apt autoremove -y --purge 2>/dev/null || true
