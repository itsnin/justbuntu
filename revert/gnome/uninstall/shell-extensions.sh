#!/bin/bash
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

reset_extension_schema() {
  local extension="$1"
  local schema="$2"
  local schema_dir="$DATA_HOME/gnome-shell/extensions/$extension/schemas"

  gsettings --schemadir "$schema_dir" reset-recursively "$schema" 2>/dev/null || true
}

# Re-enable default Ubuntu extensions
gnome-extensions enable tiling-assistant@ubuntu.com 2>/dev/null || true
gnome-extensions enable ubuntu-appindicators@ubuntu.com 2>/dev/null || true
gnome-extensions enable ubuntu-dock@ubuntu.com 2>/dev/null || true
gnome-extensions enable ding@rastersoft.com 2>/dev/null || true
gnome-extensions enable snapd-prompting@canonical.com 2>/dev/null || true
gnome-extensions enable snapd-search-provider@canonical.com 2>/dev/null || true
# Reset extension settings using each installed extension's schemas.
reset_extension_schema space-bar@luchrioh org.gnome.shell.extensions.space-bar.behavior
reset_extension_schema space-bar@luchrioh org.gnome.shell.extensions.space-bar.shortcuts
reset_extension_schema space-bar@luchrioh org.gnome.shell.extensions.space-bar.appearance
reset_extension_schema space-bar@luchrioh org.gnome.shell.extensions.space-bar.state
reset_extension_schema just-perfection-desktop@just-perfection org.gnome.shell.extensions.just-perfection
reset_extension_schema copyous@boerdereinar.dev org.gnome.shell.extensions.copyous
reset_extension_schema copyous@boerdereinar.dev org.gnome.shell.extensions.copyous.file-item
reset_extension_schema copyous@boerdereinar.dev org.gnome.shell.extensions.copyous.link-item
reset_extension_schema emoji-copy@felipeftn org.gnome.shell.extensions.emoji-copy
# Restore GNOME keybindings we modified
gsettings reset org.gnome.shell.keybindings toggle-message-tray 2>/dev/null || true
gsettings reset org.freedesktop.ibus.panel.emoji hotkey 2>/dev/null || true
# Restore workspace keybindings that we cleared for Space Bar
for i in 1 2 3 4 5 6 7 8 9; do
  gsettings reset org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" 2>/dev/null || true
done
# Uninstall all JustBuntu extensions
gext uninstall spotlight@nin 2>/dev/null || true
gnome-extensions uninstall spotlight@nin 2>/dev/null || true
gext uninstall space-bar@luchrioh 2>/dev/null || true
gnome-extensions uninstall space-bar@luchrioh 2>/dev/null || true
gext uninstall just-perfection-desktop@just-perfection 2>/dev/null || true
gnome-extensions uninstall just-perfection-desktop@just-perfection 2>/dev/null || true
gext uninstall gsconnect@andyholmes.github.io 2>/dev/null || true
gnome-extensions uninstall gsconnect@andyholmes.github.io 2>/dev/null || true
gext uninstall caffeine@patapon.info 2>/dev/null || true
gnome-extensions uninstall caffeine@patapon.info 2>/dev/null || true
gext uninstall copyous@boerdereinar.dev 2>/dev/null || true
gnome-extensions uninstall copyous@boerdereinar.dev 2>/dev/null || true
gext uninstall emoji-copy@felipeftn 2>/dev/null || true
gnome-extensions uninstall emoji-copy@felipeftn 2>/dev/null || true
# Remove extension manager packages
sudo apt purge -y gnome-shell-extension-manager gir1.2-gtop-2.0 gir1.2-clutter-1.0
pipx uninstall gnome-extensions-cli 2>/dev/null || true
