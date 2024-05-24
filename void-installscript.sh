#!/bin/sh

set -x

echo "Enter username:"
read USER

echo "Enter hostname:"
read HOSTNAME

sudo wipefs -a /dev/sda

cfdisk /dev/sda

sfdisk -d /dev/sda > sda.sfdisk

sfdisk /dev/sda < sda.sfdisk

cryptsetup luksFormat --type luks1 /dev/sda2

cryptsetup luksOpen /dev/sda2 voidvm

vgcreate voidvm /dev/mapper/voidvm

lvcreate --name root -L 30G voidvm
lvcreate --name swap -L 8G voidvm
lvcreate --name home -l 100%FREE voidvm

mkfs.btrfs -f -L root /dev/voidvm/root
mkfs.btrfs -f -L home /dev/voidvm/home
mkswap /dev/voidvm/swap

mount /dev/voidvm/root /mnt
mkdir -p /mnt/home
mount /dev/voidvm/home /mnt/home

mkfs.vfat /dev/sda1
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

xbps-install -Sy -R https://repo-default.voidlinux.org/current/ -r /mnt base-system cryptsetup grub-x86_64-efi lvm2 neovim

cp chroot.sh /mnt

xchroot /mnt ./chroot.sh
