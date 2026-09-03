#!/bin/bash

# Center new windows in the middle of the screen
gsettings set org.gnome.mutter center-new-windows true

# Reveal week numbers in the GNOME calendar
gsettings set org.gnome.desktop.calendar show-weekdate true

# Turn off ambient sensors for screen brightness. They rarely work well.
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
