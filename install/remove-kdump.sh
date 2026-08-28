#!/bin/bash
# free the kdump reserves, safe on desktop
echo "==> removing kdump-tools (frees reserved memory)"
sudo apt-get remove -y --purge kdump-tools 2>/dev/null || true
sudo rm -f /etc/default/grub.d/kdump-tools.cfg
if command -v update-grub >/dev/null 2>&1; then
  sudo update-grub 2>/dev/null || true
fi
# clean up orphans
echo "==> autoremoving orphans"
sudo apt-get autoremove -y --purge
