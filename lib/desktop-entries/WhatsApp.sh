#!/bin/bash
# detect available chromium-based browser
if command -v google-chrome-stable >/dev/null 2>&1; then
  BROWSER="google-chrome-stable"
elif command -v brave >/dev/null 2>&1; then
  BROWSER="brave"
elif command -v brave-browser >/dev/null 2>&1; then
  BROWSER="brave-browser"
elif command -v chromium >/dev/null 2>&1; then
  BROWSER="chromium"
else
  echo "no chromium-based browser found. install chrome or brave first."
  exit 1
fi

cat <<EOF >~/.local/share/applications/WhatsApp.desktop
[Desktop Entry]
Version=1.0
Name=WhatsApp
Comment=WhatsApp Messenger
Exec=$BROWSER --app="https://web.whatsapp.com" --name=WhatsApp --class=Whatsapp
Terminal=false
Type=Application
Icon=$HOME/.local/share/justbuntu/lib/desktop-entries/icons/WhatsApp.png
Categories=GTK;
MimeType=text/html;text/xml;application/xhtml_xml;
StartupNotify=true
EOF
