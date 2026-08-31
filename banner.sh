#!/bin/bash
ascii_art='
       _               _    ____            _       
      | |_   _   ___  | |_ | __ ) _   _  _ __ | |_ _   _
      | || | | |/ __| | __||  _ \| | | || '"'"'__|| __| | | |
      | || |_| |\__ \ | |_ | |_) | |_| || |   | |_| |_| |
      |_| \__,_||___/  \__||____/ \__,_||_|    \__|\__,_|
'
# green gradient shades. green holds special significance as the
# primary symbolic color in islam, associated with paradise in the quran.
colors=(
	'\033[38;5;46m'  # bright green
	'\033[38;5;82m'  # green
	'\033[38;5;76m'  # sea green
	'\033[38;5;70m'  # dark sea green
	'\033[38;5;64m'  # dark green
)
# split the ascii art into lines
IFS=$'\n' read -rd '' -a lines <<<"$ascii_art"
# print each line with the corresponding color from the gradient
for i in "${!lines[@]}"; do
	color_index=$((i % ${#colors[@]}))
	echo -e "${colors[color_index]}${lines[i]}"
done
# reset terminal color
echo -ne '\033[0m'
