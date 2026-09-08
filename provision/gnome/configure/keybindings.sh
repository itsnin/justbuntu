#!/bin/bash
# Alt+F4 is very cumbersome
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>w']"
# Make it easy to maximize, like you can fill left/right
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
# Make it easy to resize undecorated windows
gsettings set org.gnome.desktop.wm.keybindings begin-resize "['<Super>BackSpace']"
# For keyboards that only have a start/stop button for music, like Logitech MX Keys Mini
gsettings set org.gnome.settings-daemon.plugins.media-keys next "['<Shift>AudioPlay']"
# Full-screen with title/navigation bar
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Shift>F11']"
# Use 9 fixed workspaces instead of dynamic mode
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 9
# Disable the hotkeys in the Dash to Dock extension. Most likely culprit for conflicts.
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
# Use Alt for pinned apps
gsettings set org.gnome.shell.keybindings switch-to-application-1 "['<Alt>1']"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "['<Alt>2']"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "['<Alt>3']"
gsettings set org.gnome.shell.keybindings switch-to-application-4 "['<Alt>4']"
gsettings set org.gnome.shell.keybindings switch-to-application-5 "['<Alt>5']"
gsettings set org.gnome.shell.keybindings switch-to-application-6 "['<Alt>6']"
gsettings set org.gnome.shell.keybindings switch-to-application-7 "['<Alt>7']"
gsettings set org.gnome.shell.keybindings switch-to-application-8 "['<Alt>8']"
gsettings set org.gnome.shell.keybindings switch-to-application-9 "['<Alt>9']"
# Super+1..Super+0 workspace switching is handled by the Space Bar extension
# when installed. 9 fixed workspaces remain reachable via Ctrl+Alt+Arrow or
# the Activities overview when extensions are not used.
# Reserve slots for custom keybindings
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"
# Free up Super+space for the Spotlight launcher
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "@as []"
# Custom0: open file manager (Super+e)
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Files'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'nautilus'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>e'
# Custom1: start a new Ghostty window (Shift+Alt+2)
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'New Ghostty Window'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'ghostty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Shift><Alt>2'
# Custom2: start a new Chrome window (Shift+Alt+1)
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'New Chrome Window'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'google-chrome --new-window'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Shift><Alt>1'
