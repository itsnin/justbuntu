#!/bin/bash
# Revert GSConnect extension
gext uninstall gsconnect@andyholmes.github.io 2>/dev/null || true
gnome-extensions uninstall gsconnect@andyholmes.github.io 2>/dev/null || true
