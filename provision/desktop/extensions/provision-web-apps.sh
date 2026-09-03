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
elif command -v brave-origin >/dev/null 2>&1; then
  BROWSER="brave-origin"
elif command -v chromium >/dev/null 2>&1; then
  BROWSER="chromium"
fi
if [ -z "$BROWSER" ]; then
  echo "note: no chromium-based browser detected. web apps require chrome or brave."
  echo "install a browser first, then return here."
  return 0
fi
echo "using $BROWSER for web apps"
# use first-run preference if available, otherwise prompt
if [[ -n "${JUSTBUNTU_FIRST_RUN_WEB_APPS:-}" ]]; then
  SELECTED_WEB_APPS="$JUSTBUNTU_FIRST_RUN_WEB_APPS"
else
  WEB_APP_OPTIONS=("ChatGPT" "Google Drive" "Google Photos" "Google Keep" "YouTube" "Facebook" "Messenger" "Instagram" "Reddit")
  SELECTED_WEB_APPS=$(gum choose "${WEB_APP_OPTIONS[@]}" --no-limit --height 10 --header "Select web apps to install (uses $BROWSER)")
fi
if [[ -z "$SELECTED_WEB_APPS" ]]; then
  return 0
fi
ICON_DIR="$HOME/.local/share/applications/icons"
mkdir -p "$ICON_DIR"

# extract domain from url for google s2 favicon service
_get_domain() {
  local url="$1"
  # strip protocol and path, keep just the domain
  echo "$url" | sed -e 's|^[^/]*//||' -e 's|/.*$||' -e 's|^www\.||'
}

install_webapp() {
  local NAME="$1"
  local URL="$2"
  local DOMAIN
  DOMAIN=$(_get_domain "$URL")
  local DESKTOP_FILE="$HOME/.local/share/applications/${NAME}.desktop"
  local ICON_PATH="${ICON_DIR}/${NAME}.png"
  # use curated high-quality icons from dashboard-icons CDN for known apps
  # fall back to direct favicon + Google S2 for unknown apps
  declare -A ICON_MAP
  ICON_MAP["ChatGPT"]="chatgpt"
  ICON_MAP["Google Drive"]="google-drive"
  ICON_MAP["Google Photos"]="google-photos"
  ICON_MAP["Google Keep"]="google-keep"
  ICON_MAP["YouTube"]="youtube"
  ICON_MAP["Facebook"]="facebook"
  ICON_MAP["Messenger"]="facebook-messenger"
  ICON_MAP["Instagram"]="instagram"
  ICON_MAP["Reddit"]="reddit"

  ICON_SLUG="${ICON_MAP[$NAME]:-}"
  if [ -n "$ICON_SLUG" ]; then
    curl -sL --max-time 5 -o "$ICON_PATH" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/${ICON_SLUG}.png" 2>/dev/null || true
  fi
  # if CDN icon failed or unknown app, try direct favicon, then Google S2 fallback
  if [ ! -s "$ICON_PATH" ]; then
    if ! curl -sL --max-time 5 -o "$ICON_PATH" "https://${DOMAIN}/favicon.ico" 2>/dev/null || [ ! -s "$ICON_PATH" ]; then
      curl -sL --max-time 5 -o "$ICON_PATH" "https://www.google.com/s2/favicons?sz=128&domain=${DOMAIN}" 2>/dev/null || true
    fi
  fi
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
  install_webapp "ChatGPT" "https://chat.openai.com"
fi
if [[ "$SELECTED_WEB_APPS" == *"Google Drive"* ]]; then
  install_webapp "Google Drive" "https://drive.google.com"
fi
if [[ "$SELECTED_WEB_APPS" == *"Google Photos"* ]]; then
  install_webapp "Google Photos" "https://photos.google.com"
fi
if [[ "$SELECTED_WEB_APPS" == *"Google Keep"* ]]; then
  install_webapp "Google Keep" "https://keep.google.com"
fi
if [[ "$SELECTED_WEB_APPS" == *"YouTube"* ]]; then
  install_webapp "YouTube" "https://www.youtube.com"
fi
if [[ "$SELECTED_WEB_APPS" == *"Facebook"* ]]; then
  install_webapp "Facebook" "https://www.facebook.com"
fi
if [[ "$SELECTED_WEB_APPS" == *"Messenger"* ]]; then
  install_webapp "Messenger" "https://www.messenger.com"
fi
if [[ "$SELECTED_WEB_APPS" == *"Instagram"* ]]; then
  install_webapp "Instagram" "https://www.instagram.com"
fi
if [[ "$SELECTED_WEB_APPS" == *"Reddit"* ]]; then
  install_webapp "Reddit" "https://www.reddit.com"
fi
# refresh desktop database so new entries appear in app grid
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
