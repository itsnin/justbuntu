#!/bin/bash
# Reset app folder settings to defaults
gsettings reset org.gnome.desktop.app-folders folder-children
gsettings reset org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Updates/ name
gsettings reset org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Updates/ apps
gsettings reset org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Xtra/ name
gsettings reset org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/Xtra/ apps
gsettings reset org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/WebApps/ name
gsettings reset org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/WebApps/ apps
