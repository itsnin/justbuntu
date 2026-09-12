#!/bin/bash
# Reset all provisioned components. JustBuntu core (CLI, desktop icon,
# shell config, and ~/.local/share/justbuntu/) is intentionally preserved.
# Users can run `justbuntu install` to re-provision at any time.
echo "==> resetting all provisioned components"
echo "    justbuntu core will remain intact"
echo ""
REVERT_DIR="$JUSTBUNTU_PATH/revert"
position=0
success_count=0
total=0
# Count total scripts recursively from all subdirectories
while IFS= read -r script; do
  total=$((total + 1))
done < <(find "$REVERT_DIR"/general/uninstall "$REVERT_DIR"/general/deconfigure "$REVERT_DIR"/gnome/uninstall "$REVERT_DIR"/gnome/deconfigure -name "*.sh" -type f | sort)
# Run each revert script with graceful failure
while IFS= read -r script; do
  position=$((position + 1))
  name=$(basename "$script" .sh | sed 's/^revert-//')
  echo "  [$position/$total] $name"
  if source "$script"; then
    success_count=$((success_count + 1))
  else
    echo "       (failed — continuing)"
  fi
done < <(find "$REVERT_DIR"/general/uninstall "$REVERT_DIR"/general/deconfigure "$REVERT_DIR"/gnome/uninstall "$REVERT_DIR"/gnome/deconfigure -name "*.sh" -type f | sort)
echo ""
echo "==> reset complete: $success_count/$total components processed"
echo "    justbuntu core remains available. run 'justbuntu install' to re-provision."
