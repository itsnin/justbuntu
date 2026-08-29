#!/bin/bash
# install web apps as desktop entries. works with any chromium-based browser.
# detect browser first
BROWSER=""
if command -v google-chrome-stable >/dev/null 2>&1; then
  BROWSER="google-chrome-stable"
elif command -v brave >/dev/null 2>&1; then
  BROWSER="brave"
elif command -v brave-browser >/dev/null 2>&1; then
  BROWSER="brave-browser"
elif command -v chromium >/dev/null 2>&1; then
  BROWSER="chromium"
fi

if [ -z "$BROWSER" ]; then
  echo "note: no chromium-based browser detected. web apps require chrome or brave."
  echo "install a browser first, then return here."
  return 0
fi

echo "using $BROWSER for web apps"

WEB_APP_OPTIONS=("ChatGPT" "Google Photos" "Google Contacts" "Tailscale" "Facebook" "Messenger" "Instagram" "Reddit")
SELECTED_WEB_APPS=$(gum choose "${WEB_APP_OPTIONS[@]}" --no-limit --height 10 --header "Select web apps to install (uses $BROWSER)")

if [[ -z "$SELECTED_WEB_APPS" ]]; then
  return 0
fi

ICON_DIR="$HOME/.local/share/applications/icons"
mkdir -p "$ICON_DIR"

install_webapp() {
  local NAME="$1"
  local URL="$2"
  local ICON_URL="$3"
  local DESKTOP_FILE="$HOME/.local/share/applications/${NAME}.desktop"
  local ICON_PATH="${ICON_DIR}/${NAME}.png"

  curl -sL -o "$ICON_PATH" "$ICON_URL" 2>/dev/null || true

  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$NAME
Comment=$NAME
Exec=$BROWSER --app="$URL" --name="$NAME" --class="$NAME" --window-size=800,600
Terminal=false
Type=Application
Icon=$ICON_PATH
Categories=GTK;WebApps;
MimeType=text/html;text/xml;application/xhtml_xml;
StartupNotify=true
EOF
  chmod +x "$DESKTOP_FILE"
  echo "installed $NAME"
}

if [[ "$SELECTED_WEB_APPS" == *"ChatGPT"* ]]; then
  install_webapp "ChatGPT" "https://chat.openai.com" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/ChatGPT_logo.svg/240px-ChatGPT_logo.svg.png"
fi
if [[ "$SELECTED_WEB_APPS" == *"Google Photos"* ]]; then
  install_webapp "Google Photos" "https://photos.google.com" "https://www.gstatic.com/images/branding/product/2x/photos_2020q4_48dp.png"
fi
if [[ "$SELECTED_WEB_APPS" == *"Google Contacts"* ]]; then
  install_webapp "Google Contacts" "https://contacts.google.com" "https://www.gstatic.com/images/branding/product/2x/contacts_2020q4_48dp.png"
fi
if [[ "$SELECTED_WEB_APPS" == *"Tailscale"* ]]; then
  install_webapp "Tailscale" "https://login.tailscale.com/admin" "https://tailscale.com/favicon.ico"
fi
if [[ "$SELECTED_WEB_APPS" == *"Facebook"* ]]; then
  install_webapp "Facebook" "https://www.facebook.com" "https://www.facebook.com/favicon.ico"
fi
if [[ "$SELECTED_WEB_APPS" == *"Messenger"* ]]; then
  install_webapp "Messenger" "https://www.messenger.com" "https://www.messenger.com/favicon.ico"
fi
if [[ "$SELECTED_WEB_APPS" == *"Instagram"* ]]; then
  install_webapp "Instagram" "https://www.instagram.com" "https://www.instagram.com/favicon.ico"
fi
if [[ "$SELECTED_WEB_APPS" == *"Reddit"* ]]; then
  install_webapp "Reddit" "https://www.reddit.com" "https://www.reddit.com/favicon.ico"
fi
