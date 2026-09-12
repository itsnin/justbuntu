#!/bin/bash
# Revert Spotlight extension
gext uninstall spotlight@nin 2>/dev/null || true
gnome-extensions uninstall spotlight@nin 2>/dev/null || true
