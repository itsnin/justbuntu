#!/bin/bash

# center new windows in the middle of the screen
gsettings set org.gnome.mutter center-new-windows true

# set Cascadia Mono as the default monospace font
gsettings set org.gnome.desktop.interface monospace-font-name 'CaskaydiaMono Nerd Font 10'

# reveal week numbers in the Gnome calendar
gsettings set org.gnome.desktop.calendar show-weekdate true

# turn off ambient sensors for setting screen brightness (they rarely work well!)
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
