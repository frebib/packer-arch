#!/usr/bin/env bash
set -exa

DISK="/dev/vda"
FORMAT="ext4"
MNT="/mnt"

KERNEL="linux-lts"
SYS_PACK=( base-devel )

SETUP_CHROOT="setup-chroot.sh"


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
pacman -Sy
BASE_PACK=($(pacman -Sgq base | sed '/^linux$/d;' | xargs) "$KERNEL")
pacstrap $MNT ${BASE_PACK[@]} ${SYS_PACK[@]}

# Generate the system filesystem table
genfstab -U $MNT > $MNT/etc/fstab

# Set hostname
echo "$PACKER_BUILD_NAME" > $MNT/etc/hostname

# Enable sudo access for wheel
sed -i 's|# \(%wheel ALL=(ALL) ALL\)|\1|g' $MNT/etc/sudoers

# Grab and run chroot setup script
CHROOT_SCRIPT=$(basename $SETUP_CHROOT)
mv /tmp/$SETUP_CHROOT $MNT
# Pass environment through to chroot
arch-chroot $MNT /$CHROOT_SCRIPT echo $(env|xargs)
rm -f $MNT/$CHROOT_SCRIPT

