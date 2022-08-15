#!/bin/bash
echo -e "d\nd\nd\nd\n\n\nw" | fdisk /dev/sda
echo -e "n\np\n1\n\n+1G\nw" | fdisk /dev/sda
echo -e "n\np\n2\n\n\nw" | fdisk /dev/sda
mkfs.fat -F32 /dev/sda
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
pacstrap /mnt base linux linux-firmware nano neofetch
genfstab -U /mnt >> /mnt/etc/fstab
cat << EOF | arch-chroot /mnt
timedatectl set-timezone Canada/Eastern
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo aslen-pc > /etc/hostname
touch /etc/hosts
echo "127.0.0.1     localhost" > /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1     josh-pc" >> /etc/hosts
echo -e "josh\njosh" | passwd root
yes | pacman -S grub efibootmgr
mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m josh
echo -e "josh\njosh" | passwd josh
yes | pacman -S sudo nano
sed -i '80i josh ALL=(ALL) ALL' /etc/sudoers
pacman -S --noconfirm xorg-xinit xorg git base-devel networkmanager
cd /usr/src
git clone github.com/kavulox/dwm
git clone git://git.suckless.org/dmenu
systemctl enable NetworkManager.service
cd dwm
make clean install
cd ..
cd dmenu
make clean install
cd ..
pacman -Syy alacritty feh firefox 
echo "exec dwm" > /home/josh/.xinitrc 
EOF
