#!/bin/bash
# Uninstall Slack desktop
sudo apt purge -y slack-desktop 2>/dev/null || true
sudo apt autoremove -y --purge 2>/dev/null || true
