#!/bin/bash
# Uninstall nvm and Node.js
rm -rf "$HOME/.nvm"
# Remove nvm lines from shell config if present
sed -i '/NVM_DIR/d' "$HOME/.bashrc" 2>/dev/null || true
