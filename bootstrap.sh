#!/bin/bash
set -e
ascii_art='

     ___           __    ____                    __           
    |_  |_  _ ____/ /_  | __ )_  _  ____  __  __/ /___  __  __
     | || | | |_  / __ \ |  _ \| | | |/_  / / / / / //_/ / / / /
 /\__/ || |_| |/ / /_/ / | |_) | |_| | / /| |_| | / ,< / /_/ /_/ / 
 \____/ \__,_/___/\____/  |____/ \__,_/___|\__,_/_/_/|_|\__/\__, /  
                                                            /____/   

'
echo -e "$ascii_art"
echo "=> JustBuntu is for fresh Ubuntu 26.04 LTS or newer installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."
sudo apt-get update >/dev/null
sudo apt-get install -y git wget curl >/dev/null
echo "Cloning JustBuntu..."
rm -rf ~/.local/share/justbuntu
git clone https://github.com/itsnin/justbuntu.git ~/.local/share/justbuntu >/dev/null
if [[ -n "${JUSTBUNTU_REF:-}" ]] && [[ $JUSTBUNTU_REF != "main" ]]; then
	cd ~/.local/share/justbuntu
	git fetch origin "${JUSTBUNTU_REF:-main}" && git checkout "${JUSTBUNTU_REF:-main}"
	cd -
fi
echo "Installation starting..."
source ~/.local/share/justbuntu/install.sh
