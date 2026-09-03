#!/bin/bash
ascii_art='
       _               _    ____            _       
      | |_   _   ___  | |_ | __ ) _   _  _ __ | |_ _   _
      | || | | |/ __| | __||  _ \| | | || '"'"'__|| __| | | |
      | || |_| |\__ \ | |_ | |_) | |_| || |   | |_| |_| |
      |_| \__,_||___/  \__||____/ \__,_||_|    \__|\__,_|
'
# Green gradient shades. Green holds special significance as the
# primary symbolic color in Islam, associated with paradise in the Quran.
colors=(
	'\033[38;5;46m'  # Bright green
	'\033[38;5;82m'  # Green
	'\033[38;5;76m'  # Sea green
	'\033[38;5;70m'  # Dark sea green
	'\033[38;5;64m'  # Dark green
)
# Split the ASCII art into lines
IFS=$'\n' read -rd '' -a lines <<<"$ascii_art"
# Print each line with the corresponding color from the gradient
for i in "${!lines[@]}"; do
	color_index=$((i % ${#colors[@]}))
	echo -e "${colors[color_index]}${lines[i]}"
done
# Reset terminal color
echo -ne '\033[0m'
