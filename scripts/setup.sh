#!/usr/bin/env bash
set -exa

# Update the system clock
timedatectl set-ntp true

# Create and format the disk partitions
parted=( parted -s -a optimal )
${parted[@]} $DISK mklabel gpt
${parted[@]} $DISK mkpart ext4 1 2
${parted[@]} $DISK mkpart $FORMAT 2 100%
${parted[@]} $DISK set 1 bios_grub on
mkfs.$FORMAT "$DISK"2

# Mount the root partition
mount "$DISK"2 $MNT

# Install system packages
[ -n "$REPO" ] && echo "$REPO" | sed 's|\s|\n|g' | sed 's|^|Server = |g' > /etc/pacman.d/mirrorlist
pacman -Sy
PKG_BASE="$(comm -23 <(pacman -Sgq base | sort) <(echo "$PKG_IGNORE linux" | sed 's|\s|\n|g' | sort) | xargs) $KERNEL"
pacstrap $MNT $PKG_BASE $PKG_INSTALL

# Generate the system filesystem table
genfstab -U $MNT > $MNT/etc/fstab

# Set hostname
echo "$PACKER_BUILD_NAME" > $MNT/etc/hostname

# Enable sudo access for wheel
sed -i 's|# \(%wheel ALL=(ALL) ALL\)|\1|g' $MNT/etc/sudoers

# Grab and run chroot setup script
run-chroot setup-chroot.sh
