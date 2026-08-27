#!/bin/bash
# Let user choose which browser to install
BROWSER_CHOICES=("Chrome" "Brave" "None")
DEFAULT_BROWSER="Chrome"
CHOICE=$(gum choose "${BROWSER_CHOICES[@]}" --selected "$DEFAULT_BROWSER" --height 5 --header "Select a browser to install")

if [[ "$CHOICE" == "Chrome" ]]; then
  # browse the web with the most popular browser
  cd /tmp
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install -y ./google-chrome-stable_current_amd64.deb
  rm google-chrome-stable_current_amd64.deb
  xdg-settings set default-web-browser google-chrome.desktop
  cd -
elif [[ "$CHOICE" == "Brave" ]]; then
  # install brave browser
  if [ ! -f /etc/apt/sources.list.d/brave-browser-release.list ]; then
    [ -f /usr/share/keyrings/brave-browser-archive-keyring.gpg ] && sudo rm /usr/share/keyrings/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  fi
  sudo apt update
  sudo apt install -y brave-browser
  xdg-settings set default-web-browser brave-browser.desktop
fi
