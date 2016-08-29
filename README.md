# Arch Linux VM - built with Packer

A virtual machine builder for a base arch-linux installation.
The VM is installed with `base` and `base-devel`, running the `linux-lts` kernel

### Provisioner

By default the script builds `arch.box` in a Vagrant box format for easy deployment
The resulting file size is about ~644Mb

## TODO:
- Use syslinux instead of grub, it's lighter
- Separate out configuration into a separate file
- Slim down package list; remove some useless packages
