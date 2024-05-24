#!/bin/sh

set -x

chown root:root /

chmod 755 /

passwd root

echo void > /etc/hostname

xbps-install neovim

echo "/dev/voidvm/root  /     btrfs     defaults              0       0" >> /etc/fstab
echo "/dev/voidvm/home  /home btrfs     defaults              0       0" >> /etc/fstab
echo "/dev/voidvm/swap  swap  swap    defaults              0       0" >> /etc/fstab
echo "/dev/sda1	/boot/efi	vfat	defaults	0	0" >> /etc/fstab

echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub

echo "rd.lvm.vg=voidvm rd.luks.uuid=<UUID>" >> /etc/default/grub

blkid -o value -s UUID /dev/sda2 >> /etc/default/grub

nvim /etc/default/grub

dd bs=1 count=64 if=/dev/urandom of=/boot/volume.key

cryptsetup luksAddKey /dev/sda2 /boot/volume.key

chmod 000 /boot/volume.key
chmod -R g-rwx,o-rwx /boot

echo "voidvm   /dev/sda1   /boot/volume.key   luks" >> /etc/crypttab

echo "install_items+=\" /boot/volume.key /etc/crypttab \"" > /etc/dracut.conf.d/10-crypt.conf

grub-install /dev/sda && xbps-reconfigure -fa
