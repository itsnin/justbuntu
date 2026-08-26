#!/bin/bash

set -e

ascii_art='
       __           __    __          __          
  ____/ /_  _______/ /_  / /_  ____  / /___  __  __
 / __  / / / / ___/ __ \/ __ \/ __ \/ //_/ / / / /
/ /_/ / /_/ (__  ) / / / /_/ / / / / ,< / /_/ /_/ / 
\__,_/\__,_/____/_/ /_/\____/_/ /_/_/|_|\__/\__, /  
                                           /____/   
'

echo -e "$ascii_art"
echo "=> Justbuntu is for fresh Ubuntu 26.04 LTS or newer installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Justbuntu..."
rm -rf ~/.local/share/justbuntu
git clone https://github.com/itsnin/justbuntu.git ~/.local/share/justbuntu >/dev/null
if [[ $JUSTBUNTU_REF != "main" ]]; then
	cd ~/.local/share/justbuntu
	git fetch origin "${JUSTBUNTU_REF:-main}" && git checkout "${JUSTBUNTU_REF:-main}"
	cd -
fi

echo "Installation starting..."
source ~/.local/share/justbuntu/install.sh
