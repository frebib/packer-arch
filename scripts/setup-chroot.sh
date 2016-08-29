#!/bin/bash
set -ex

LANG="en_GB.UTF-8"
LOCALE="$LANG UTF-8"

EXTRA_PACK=( openssh )

# Set the local timezone
ln -s /usr/share/zoneinfo/$ZONEINFO /etc/localtime

# Set system locale
echo "$LOCALE" > /etc/locale.gen
echo "LANG=$LANG" > /etc/locale.conf
locale-gen

# Build kernel image (Redundant as is built on kernel installation)
#mkinitcpio -p $KERNEL

# Disable persistent network names
# Source: https://github.com/medvid/arch-packer/blob/master/http/setup-chroot.sh
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
systemctl enable dhcpcd@eth0

# Install some packages
pacman -Sy --noconfirm ${EXTRA_PACK[@]}

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

# Setup grub
pacman -S grub --noconfirm
grub-install --target=i386-pc $DISK

# Generate grub config
sed -i 's|^\(GRUB_HIDDEN_TIMEOUT_QUIET=\).*|\1true|; s|^\(GRUB_TIMEOUT=\).*|\11|' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Enable some services
systemctl enable sshd

# Clear pacman cache
pacman -Scc --noconfirm
pacman-optimize

# Set a random root password
root_pw="< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32"
echo -e "${root_pw}\n${root_pw}\n" | passwd root

# Write zeros to improve virtual disk compaction.
# Source: https://github.com/elasticdog/packer-arch/blob/master/scripts/cleanup.sh
zerofile=$(/usr/bin/mktemp /zerofile.XXXXX)
/usr/bin/dd if=/dev/zero of="$zerofile" bs=1M || true
/usr/bin/rm -f "$zerofile"
/usr/bin/sync

