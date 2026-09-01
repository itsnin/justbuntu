#!/bin/bash
if [ ! -f "/etc/apt/sources.list.d/github-cli.list" ]; then
    [ -f "/usr/share/keyrings/githubcli-archive-keyring.gpg" ] && sudo rm /usr/share/keyrings/githubcli-archive-keyring.gpg
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg status=none
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
fi
sudo apt update
sudo apt install gh -y || echo "github cli install failed (continuing)"
# optionally authenticate with github
if [[ "${JUSTBUNTU_GITHUB_AUTH:-}" == "true" ]]; then
  echo "==> starting github authentication (browser-based)"
  gh auth login --web --git-protocol https 2>/dev/null || echo "github auth skipped or failed (you can run 'gh auth login' later)"
  gh auth setup-git 2>/dev/null || true
fi
