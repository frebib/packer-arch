#!/bin/bash
set -exa

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

# Install some packages
pacman -Sy --noconfirm $PKG_EXTRA

# Symlink vim to vi
which vim && ln -sfv $(which vim) /usr/bin/vi || true

# Setup grub
pacman -S grub --noconfirm
grub-install --target=i386-pc $DISK

# Generate grub config
sed -i 's|^\(GRUB_HIDDEN_TIMEOUT_QUIET=\).*|\1true|; s|^\(GRUB_TIMEOUT=\).*|\11|' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Enable some services
systemctl enable sshd

# Set a random root password
root_pw="$(</dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)"
echo -e "${root_pw}\n${root_pw}\n" | passwd root

