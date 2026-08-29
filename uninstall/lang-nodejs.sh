#!/bin/bash
# uninstall nvm and node.js
rm -rf "$HOME/.nvm"
# remove nvm lines from shell config if present
sed -i '/NVM_DIR/d' "$HOME/.bashrc" 2>/dev/null || true
