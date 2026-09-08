#!/bin/bash
# Install GitHub CLI (gh) from Ubuntu repositories
sudo apt update
sudo apt install -y gh || echo "github cli install failed (continuing)"
