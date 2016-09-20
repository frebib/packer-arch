#!/usr/bin/env bash
set -exa

# Clear pacman cache
pacman -Scc --noconfirm
pacman-optimize

# Write zeros to improve virtual disk compaction.
# Source: https://github.com/elasticdog/packer-arch/blob/master/scripts/cleanup.sh
zerofile=$(mktemp /zerofile.XXXXX)
dd if=/dev/zero of="$zerofile" bs=1M || true
rm -f "$zerofile"
sync
