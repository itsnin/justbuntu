#!/bin/bash
ascii_art='

     ___           __    ____                    __           
    |_  |_  _ ____/ /_  | __ )_  _  ____  __  __/ /___  __  __
     | || | | |_  / __ \ |  _ \| | | |/_  / / / / / //_/ / / / /
 /\__/ || |_| |/ / /_/ / | |_) | |_| | / /| |_| | / ,< / /_/ /_/ / 
 \____/ \__,_/___/\____/  |____/ \__,_/___|\__,_/_/_/|_|\__/\__, /  
                                                            /____/   

'
# define the color gradient (shades of cyan and blue)
colors=(
	'\033[38;5;81m' # cyan
	'\033[38;5;75m' # light blue
	'\033[38;5;69m' # sky blue
	'\033[38;5;63m' # dodger blue
	'\033[38;5;57m' # deep sky blue
	'\033[38;5;51m' # cornflower blue
	'\033[38;5;45m' # royal blue
)
# split the ASCII art into lines
IFS=$'\n' read -rd '' -a lines <<<"$ascii_art"
# print each line with the corresponding color
for i in "${!lines[@]}"; do
	color_index=$((i % ${#colors[@]}))
	echo -e "${colors[color_index]}${lines[i]}"
done
