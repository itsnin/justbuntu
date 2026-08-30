# Command Execution Patterns

## Overview

Execute external commands safely, correctly, and efficiently.

**Confidence**: Verified via security-anti-patterns sources, bash-style-guide repo, and OWASP guidance just now.

## Command Substitution

```bash
# PREFERRED — $() syntax, nestable
files=$(ls *.txt)

# AVOID — backticks, hard to nest, readability poor
files=`ls *.txt`

# ALWAYS quote the expansion unless you want word splitting
echo "$files"    # RIGHT
echo $files      # WRONG — word splitting and glob expansion
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
if [[ $? -eq 0 ]]; then ...   # $? is from echo, always 0!
```

## Pipes and `pipefail`

```bash
# Without pipefail — only grep's exit code matters
# If find fails, the pipeline still "succeeds"
find / -name "*.conf" | grep "network"

# WITH set -o pipefail — any failure in the pipeline is caught
set -o pipefail
find / -name "*.conf" | grep "network"   # find failure = pipeline failure
```

## `xargs` Safety

```bash
# DANGEROUS — breaks on filenames with spaces/newlines
find . -name "*.txt" | xargs rm

# SAFE — null-delimited, handles any filename
find . -name "*.txt" -print0 | xargs -0 rm
```

## Running Commands from Variables

```bash
# DANGEROUS — word splitting, cannot handle spaces
cmd="wget -O my file.tar.gz $url"
$cmd   # Breaks: "my" and "file.tar.gz" treated as separate args

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
# Wrap downloads in conditionals
if wget -q -O "$dest" "$url"; then
    process_file "$dest"
else
    echo "download failed: $url" >&2
    return 1
fi

# Follow redirects
wget -L -O "$dest" "$url"   # -L follows redirects
curl -fsSL -o "$dest" "$url"  # -f fail silently, -s silent, -S show errors, -L follow redirects
```

## `cd` in Subshells

```bash
# DANGEROUS — if script crashes mid-execution, parent shell's cwd is /tmp
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
# Parent shell cwd is unchanged
```

**Self-challenge**: If this command fails, does the script continue in a broken state? Under `set -e`, it will abort — but only if the failure is not masked by being in a conditional or `||` chain.
