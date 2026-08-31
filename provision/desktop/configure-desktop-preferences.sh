#!/bin/bash

# center new windows in the middle of the screen
gsettings set org.gnome.mutter center-new-windows true

# reveal week numbers in the Gnome calendar
gsettings set org.gnome.desktop.calendar show-weekdate true

# turn off ambient sensors for setting screen brightness (they rarely work well!)
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
