#!/bin/bash
set -exa

# Set the local timezone
ln -sf /usr/share/zoneinfo/$ZONEINFO /etc/localtime

# Set system locale
echo "$LOCALE" > /etc/locale.gen
echo "LANG=$LANG" > /etc/locale.conf
[ -n "$REPO" ] && echo "$REPO" | sed 's|\s|\n|g' | sed 's|^|Server = |g' > /etc/pacman.d/mirrorlist
locale-gen

# Build kernel image (Redundant as is built on kernel installation)
#mkinitcpio -p $KERNEL

# Disable persistent network names
# Source: https://github.com/medvid/arch-packer/blob/master/http/setup-chroot.sh
ln -sf /dev/null /etc/udev/rules.d/80-net-setup-link.rules

# Install some packages
pacman -Sy --noconfirm $PKG_EXTRA

# Symlink vim to vi
which vim && ln -sfv $(which vim) /usr/bin/vi || true

# Enable some services
systemctl enable sshd

# Set a random root password
root_pw="$(</dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)"
echo -e "\n\n\nTHE ROOT PASSWORD:\n\t${root_pw}\n\n\n"
echo -e "${root_pw}\n${root_pw}\n" | passwd root

# Setup grub
pacman -S grub --noconfirm
grub-install --target=i386-pc $DISK

# Generate grub config
sed -i 's|^\(GRUB_HIDDEN_TIMEOUT_QUIET=\).*|\1true|; s|^\(GRUB_TIMEOUT=\).*|\11|' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
