# Arrays and Argument Parsing

## Overview

Use arrays for structured data and safe argument handling. Arrays eliminate word-splitting bugs.

**Confidence**: Verified via coding-style-guide repo and general bash best practices just now.

## Array Basics

```bash
# Declaration
items=()                      # empty array
items=("apple" "banana" "cherry")  # with values
items+=("date")                # append

# Access — ALWAYS quote the expansion
echo "${items[0]}"             # first element
echo "${items[@]}"             # all elements (SAFE — each element preserved)
echo "${#items[@]}"            # array length
echo "${!items[@]}"            # indices

# Iteration
for item in "${items[@]}"; do
    process_item "$item"
done
```

## Building Commands Safely with Arrays

Arrays are the ONLY safe way to build dynamic commands:

```bash
# RIGHT — build command as array, each element preserved
cmd_args=()
cmd_args+=("--output")
cmd_args+=("$output_file")
if [[ "$verbose" -eq 1 ]]; then
    cmd_args+=("--verbose")
fi
cmd_args+=("$input_file")

my_command "${cmd_args[@]}"

# DANGEROUS — word splitting breaks paths with spaces
cmd="my_command --output $output_file $input_file"
$cmd  # Breaks if $output_file contains spaces
```

## Argument Parsing with `getopts`

```bash
# Parse short options: -v -o FILE -h
verbose=0
output_file=""

while getopts "vo:h" opt; do
    case "$opt" in
        v) verbose=1 ;;
        o) output_file="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# Remaining positional arguments are now in $1, $2, ...
input_file="$1"
```

## Manual Argument Parsing

For long options (`--help`, `--output=FILE`):

```bash
args=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --output=*)
            output_file="${1#*=}"
            shift
            ;;
        --output)
            output_file="$2"
            shift 2
            ;;
        --)
            shift
            args+=("$@")
            break
            ;;
        -*)
            echo "error: unknown option: $1" >&2
            exit 1
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done
```

## Passing Arguments Through

```bash
# Pass ALL arguments through to another command
# RIGHT — preserves each argument exactly
wrapper() {
    underlying_command "$@"
}

# WRONG — flattens arguments, word-splits
wrapper() {
    underlying_command $*
}
```

**Self-challenge**: Are you using a string to build a command? If yes, you have a word-splitting bug waiting to happen. Use an array instead.
