#!/bin/bash
set -e
ascii_art='
       _               _    ____            _       
      | |_   _   ___  | |_ | __ ) _   _  _ __ | |_ _   _
      | || | | |/ __| | __||  _ \| | | || '\''__|| __| | | |
      | || |_| |\__ \ | |_ | |_) | |_| || |   | |_| |_| |
      |_| \__,_||___/  \__||____/ \__,_||_|    \__|\__,_|
'
# print in green
echo -ne '\033[38;5;46m'
echo -e "$ascii_art"
echo -ne '\033[0m'
echo "=> JustBuntu is for fresh Ubuntu 26.04 LTS or newer installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."
sudo apt-get update >/dev/null
sudo apt-get install -y git wget curl >/dev/null
echo "Cloning JustBuntu..."
rm -rf "$HOME/.local/share/justbuntu"
git clone https://github.com/itsnin/justbuntu.git "$HOME/.local/share/justbuntu" >/dev/null
if [[ -n "${JUSTBUNTU_REF:-}" ]] && [[ $JUSTBUNTU_REF != "main" ]]; then
	cd "$HOME/.local/share/justbuntu"
	git fetch origin "${JUSTBUNTU_REF:-main}" && git checkout "${JUSTBUNTU_REF:-main}"
	cd -
fi
echo "Installation starting..."
source "$HOME/.local/share/justbuntu/provision/orchestrate.sh"
