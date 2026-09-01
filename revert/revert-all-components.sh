#!/bin/bash
# reset all provisioned components. justbuntu core (cli, desktop icon,
# shell config, and ~/.local/share/justbuntu/) is intentionally preserved.
# users can run `justbuntu install` to re-provision at any time.
echo "==> resetting all provisioned components"
echo "    justbuntu core will remain intact"
echo ""
REVERT_DIR="$JUSTBUNTU_PATH/revert"
position=0
success_count=0
total=0
# count total scripts first (excluding this one)
for script in "$REVERT_DIR/revert-"*.sh; do
  [[ "$(basename "$script")" == "revert-all-components.sh" ]] && continue
  total=$((total + 1))
done
# run each revert script with graceful failure
for script in "$REVERT_DIR/revert-"*.sh; do
  [[ "$(basename "$script")" == "revert-all-components.sh" ]] && continue
  position=$((position + 1))
  name=$(basename "$script" .sh | sed 's/^revert-//')
  echo "  [$position/$total] $name"
  if source "$script"; then
    success_count=$((success_count + 1))
  else
    echo "       (failed — continuing)"
  fi
done
echo ""
echo "==> reset complete: $success_count/$total components processed"
echo "    justbuntu core remains available. run 'justbuntu install' to re-provision."
