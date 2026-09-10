# Command Execution Patterns

## Command Substitution

```bash
# PREFERRED — $() syntax, nestable
files=$(ls *.txt)

# AVOID — backticks, hard to nest
files=`ls *.txt`

# ALWAYS quote the expansion unless you want word splitting
echo "$files"
```

## Checking Command Success

```bash
# RIGHT — check directly in conditional
if wget -q -O file.tar.gz "$url"; then
    echo "download succeeded"
fi

# ALSO RIGHT — explicit exit code check when needed
wget -q -O file.tar.gz "$url"
exit_code=$?
if [[ $exit_code -ne 0 ]]; then
    echo "download failed (exit $exit_code)" >&2
fi

# WRONG — $? captures the 'echo' exit code, not the wget exit code
wget -q -O file.tar.gz "$url"
echo "download done"
if [[ $? -eq 0 ]]; then ...
```

## Pipes and `pipefail`

```bash
# Without pipefail — only grep's exit code matters
find / -name "*.conf" | grep "network"

# WITH set -o pipefail — any failure in the pipeline is caught
set -o pipefail
find / -name "*.conf" | grep "network"
```

## `xargs` Safety

```bash
# DANGEROUS — breaks on filenames with spaces or newlines
find . -name "*.txt" | xargs rm

# SAFE — null-delimited, handles any filename
find . -name "*.txt" -print0 | xargs -0 rm
```

## Running Commands from Variables

```bash
# DANGEROUS — word splitting, cannot handle spaces
cmd="wget -O my file.tar.gz $url"
$cmd

# SAFE — use arrays
cmd_args=(wget -O "my file.tar.gz" "$url")
"${cmd_args[@]}"
```

## `sudo` Usage

- Add `sudo` ONLY to commands that genuinely need root privileges
- Never add `sudo` to commands that don't require it
- Never remove `sudo` from commands that genuinely need it
- Don't run entire scripts with `sudo` — apply it selectively

## Download Safety

```bash
if wget -q -O "$dest" "$url"; then
    process_file "$dest"
else
    echo "download failed: $url" >&2
    return 1
fi
```

## `cd` in Subshells

```bash
# DANGEROUS — if script crashes, parent shell's cwd is changed
cd /tmp
wget ...
tar xf ...
cd -

# SAFE — subshell isolates directory change
(
    cd /tmp || exit 1
    wget ...
    tar xf ...
)
```

## Process Substitution

```bash
# Compare outputs of two commands
diff <(sort file1.txt) <(sort file2.txt)

# Avoid subshell variable loss with process substitution
last_line=""
while read -r line; do
    last_line="$line"
done < <(your_command)
```
