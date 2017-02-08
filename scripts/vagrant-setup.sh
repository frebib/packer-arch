#!/usr/bin/env bash
set -exa

pacman -S python2 --noconfirm --needed

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
rm -f /etc/systemd/network/default.network
cat << EOF > /etc/systemd/network/global.network
[Match]
Name=eth1
[Network]
DHCP=ipv4
[DHCP]
RouteMetric=20
EOF
cat << EOF > /etc/systemd/network/vagrant.network
[Match]
Name=eth0
[Network]
DHCP=ipv4
[DHCP]
RouteMetric=100
UseDNS=false
EOF

# Trick Vagrant into thinking netctl is installed :roll_eyes:
mkdir -p /etc/netctl
ln -sfv /bin/true /usr/bin/netctl
