#!/bin/bash
# let user select which browsers to install. multi-select possible.
BROWSER_OPTIONS=("Chrome" "Brave Origin" "None")
DEFAULT_BROWSER="Chrome"
SELECTED_BROWSERS=$(gum choose "${BROWSER_OPTIONS[@]}" --no-limit --selected "$DEFAULT_BROWSER" --height 6 --header "Select browsers to install (multi-select enabled)")

if [[ "$SELECTED_BROWSERS" == *"None"* ]] && [[ -n "$SELECTED_BROWSERS" ]]; then
  echo "note: no browser selected. web applications feature requires chrome to function."
  echo "you have been warned."
  return 0
fi

if [[ -z "$SELECTED_BROWSERS" ]]; then
  echo "note: no browser selected. web applications feature requires chrome to function."
  return 0
fi

if [[ "$SELECTED_BROWSERS" != *"Chrome"* ]]; then
  echo "note: chrome not selected. be advised that the web applications feature depends on chrome."
fi

if [[ "$SELECTED_BROWSERS" == *"Chrome"* ]]; then
  # install google chrome via direct .deb
  # apt-get install resolves chrome's deps, and the .deb postinst
  # also adds google's apt repo so future apt upgrade pulls chrome updates
  echo "==> installing google chrome (direct .deb)"
  wget -q -O /tmp/google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt-get install -y /tmp/google-chrome-stable.deb || echo "chrome install failed (continuing)"
  rm -f /tmp/google-chrome-stable.deb
  xdg-settings set default-web-browser google-chrome.desktop
fi

if [[ "$SELECTED_BROWSERS" == *"Brave Origin"* ]]; then
  # install brave origin using deb822 .sources format
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
  sudo apt update
  sudo apt install -y brave-origin
  # set chrome as default if both selected, otherwise brave
  if [[ "$SELECTED_BROWSERS" != *"Chrome"* ]]; then
    xdg-settings set default-web-browser brave-browser.desktop
  fi
fi
