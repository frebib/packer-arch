#!/usr/bin/env bash
set -exa

# Vagrant default user
user="vagrant"
useradd -m $user
echo -e "${user}\n${user}\n" | passwd ${user}
echo "${user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${user}
chmod 0440 /etc/sudoers.d/${user}
install -d -o ${user} -g ${user} -m 0700 /home/${user}/.ssh
curl -L https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub > /home/${user}/.ssh/authorized_keys 
chown ${user}:${user} /home/${user}/.ssh/authorized_keys

# Disable password login for the default user
echo -e "Match User ${user}\n    PasswordAuthentication no" >> /etc/ssh/sshd_config

# Configure network for running in Vagrant
mkdir -p /run/systemd/resolve

systemctl enable systemd-resolved
systemctl enable systemd-networkd
systemctl enable systemd-networkd-wait-online

echo -e "[Match]\nName=eth1\n[Network]\nDHCP=ipv4\n[DHCP]\nRouteMetric=20" > "/etc/systemd/network/global.network"
echo -e "[Match]\nName=eth0\n[Network]\nDHCP=ipv4\n[DHCP]\nRouteMetric=100\nUseDNS=false" > "/etc/systemd/network/vagrant.network"

# Trick Vagrant into thinking netctl is installed :roll_eyes:
mkdir -p /etc/netctl
ln -sfv /bin/true /usr/bin/netctl
