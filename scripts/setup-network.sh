#!/usr/bin/env bash
set -exa

mkdir -p /run/systemd/resolve

systemctl enable systemd-resolved
systemctl enable systemd-networkd
systemctl enable systemd-networkd-wait-online

cat << EOF > /etc/systemd/network/default.network
[Match]
Name=eth*
[Network]
DHCP=ipv4
EOF
