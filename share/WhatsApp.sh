#!/bin/bash
# Detect available Chromium-based browser
if command -v google-chrome-stable >/dev/null 2>&1; then
  BROWSER="google-chrome-stable"
elif command -v brave >/dev/null 2>&1; then
  BROWSER="brave"
elif command -v brave-browser >/dev/null 2>&1; then
  BROWSER="brave-browser"
elif command -v brave-origin >/dev/null 2>&1; then
  BROWSER="brave-origin"
elif command -v chromium >/dev/null 2>&1; then
  BROWSER="chromium"
else
  echo "warning: no chromium-based browser found. skipping whatsapp desktop entry."
  return 0
fi

cat <<EOF >"$HOME/.local/share/applications/WhatsApp.desktop"
[Desktop Entry]
Version=1.0
Name=WhatsApp
Comment=WhatsApp Messenger
Exec=$BROWSER --app="https://web.whatsapp.com" --name=WhatsApp --class=Whatsapp
Terminal=false
Type=Application
Icon=$HOME/.local/share/justbuntu/share/icons/WhatsApp.png
Categories=GTK;
MimeType=text/html;text/xml;application/xhtml_xml;
StartupNotify=true
EOF
