#!/bin/bash
# Revert Caffeine extension
gext uninstall caffeine@patapon.info 2>/dev/null || true
gnome-extensions uninstall caffeine@patapon.info 2>/dev/null || true
