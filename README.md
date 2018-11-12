## arch/i3 installation 

### Prepare usb stick

download arch iso 
show your drives
```
$ lsblk
```
plug in your usb stick and show your drives again, remember the name of the usb stick
    $ lsblk
change user to root
    $ su root
then use dd (knowwn as disk destroyer) to put the iso on the usb stick
    # dd if=Downloads/archlinux-2018.10.01-x86_64.iso of=/dev/sdb status="progress"

### Partition and mount your hard drive

boot from usb
that will give you an arch installer root command line
double check that your computer doesn't need efi install
if these files exist, you do need efi install
# ls /sys/firmware/efi/efivars 
then connect to a wifi network with # wifi-menu
make sure you have a an ip with # ip a
or you can ping a website
# ping brianhaller.net

update system time
# timedatectl set-ntp true

partition hd
identify your hd
# fdisk -l or lsblk -f
that should show your hd as /dev/sda
open the fdisk command prompt
# fdisk /dev/sda
delete all exiting partitions (repeat this command until all partitions are
deleted
d 
    default
You want to create 4 partitions - boot, swap, root, home
p (print - to check the state of the drive)
n (new partition)
    p (primary)
    default 1 (partition number)
    default 2048 (first sector)
    +200M (last sector)
p (print - should see new partition)
Then make 3 more partitions of sizes 
swap - 12G
root - 25G
home - the rest of the drive (leave empty, just press enter)
w (write the changes)

format the partitions with the ext4 file system (do not format the swap
partition)
# mkfs.ext4 /dev/sda1
# mkfs.ext4 /dev/sda3
# mkfs.ext4 /dev/sda4

format the swap partition
# mkswap /dev/sda2
# swapon /dev/sda2

mount the partitions
show that the partitions are not yet mounted
# lsblk
# mount /dev/sda3 /mnt
# mkdir /mnt/home
# mkdir /mnt/boot
# mount /dev/sda4 /mnt/home
# mount /dev/sda1 /mnt/boot

###################################################
Install arch and boot from hard drive

install arch with pacstrap
# pacstrap /mnt base base-devel

generate fstab file 
fstab is a text file that contains a list of partitions for the bootloader to
use
# genfstab -U /mnt >> /mnt/etc/fstab

get into the arch install and off the usb
# arch-chroot /mnt

# install grub (bootloader), network tools, and vim
# pacman -S networkmanager dialog grub vim

configure grub
# grub-install --target=i386-pc /dev/sda
# grub-mkconfig -o /boot/grub/grub.cfg

set root password
# passwd

set the locale by uncommenting en_US.UTF-8 UTF-8 and en_US ISO-8859-1 
# vim /etc/locale.gen
set the locale
# locale-gen
write LANG=en_US.UTF-8 to /etc/locale.conf (that will be a new file)
# vim /etc/locale.conf
set the timezone
# ln -sf /usr/share/zoneinfo/America/Los_Angeles (or Denver) /etc/localtime

set hostname to arch-thinkpad
# vim /etc/hostname

unmount everything (optional, and never seems to work...)
# umount -R /mnt

reboot and remove usb
# exit
# reboot 

At this point you have completed the basic arch install
you are in a tty and can login as root
if things go wrong, you can get to a new tty with ctrl alt f(1, 2, 3,...)
alt left arrow (or right arrow) will switch between ttys

##############################################################
Install window manager and more software

connect to wifi
# wifi-menu 

create a user and put it in the wheel group
# useradd -m -g wheel bsh
add password
# passwd bsh
give bsh sudo priveliges by uncommenting the line that gives sudo privileges to members of the wheel group 
choose the line that also removes the need for a password
# vim /etc/sudoers

Install xorg to be able to run graphical environments
find your video card
# lspci
I think I have an intel integrated video card (is it graphics?)
# pacman -S xf86-video-intel 
install xorg stuff. You don't need it all but I'm not exacty sure which are
necessary. I also don't know if you have to specify xorg-xinit
# pacman -S xorg xorg-xinit 
How does xorg work? When you run xinit or startx the x server starts. It reads
.xinitrc to know what graphical environment to start
create .xinitrc and write "exec i3"
# vim /home/bsh/.xinitrc
install the standard i3 stuff
# pacman -S i3-wm i3blocks i3lock rxvt-unicode dmenu
install fonts
# pacman -S ttf-linux-libertine ttf-inconsolata
start i3 as bsh (reboot and sign in as bsh)
$ startx

#########################################
configure everything else

set wifi
$ systemctl start NetworkManager.service
$ systemctl enable NetworkManager.service
$ nmcli device wifi list 
$ nmcli device wifi connect <SSID> password <password> 

a bunch more installs 
$ sudo pacman -S xcape firefox git ranger gvim 

git clone your dotfiles repo
move your dotfiles into the home directory

enable copy and paste
move .vimrc and .vim folder into place (you need to add .vim to dotfiles repo)

enable audio and  unmute the sound (for some reason it is muted by default)
$ sudo pacman -S alsa-utils pulseaudio
$ amixer sset Master unmute
$ amixer sset Speaker unmute
$ amixer sset Headphone unmute

if brightness controls don't work try using light-git from the aur
$ git clone https://aur.archlinux.org/light-git.git
increase brightness
$ light -A 5
decrease brightness
# light -U 5
There should be lines in the i3 config for connecting those commands with
brightness keys

download perl scripts for urxvt extras
$ sudo pacman -S urxvt-perls
$ git clone https://aur.archlinux.org/urxvt-resize-font-git.git
$ cd urxvit-resize-font-git
$ makepkg -si

enable bluetooth for headphones
install pulseaudio-alsa, pulseaudio-bluetooth, bluez, bluez-libs, bluez-utils
$ systemctl start bluetooth.service
$ systemctl enable bluetooth.service
$ bluetoothctl
[bluetooth]# power on
[bluetooth]# agent on
[bluetooth]# default-agent
[bluetooth]# scan on
[bluetooth]# pair <mac address>
[bluetooth]# connect <mac address>
[bluetooth]# trust <mac address>
if this step fails,$ pulseaudio -k, then try again
[bluetooth]# scan off
[bluetooth]# exit
add "load-module module-switch-on-connect" to the bottom of
/etc/pulse/default.pa
add "AutoEnable=true" to the bottom of /etc/bluetooth/main.conf

transfer files from usb backup
$ sudo mkdir /mnt/usbdrive
$ sudo chown bsh:wheel /mnt/usbdrive
$ sudo mount -o gid=wheel,fmask=113,dmask=002 /dev/<drive name> /mnt/usbdrive

#########################################
this is from the other arch material I have read...

install more packages
grub is necessary to boot (I think it is the bootloader), the others are optional but good
linux-lts is the more stable linux kernel
# pacman -S openssh grub-bios linux-headers linux-lts linux-lts-headers

install a bunch more packages that are good for wireless networking
dialog is the UI used in wifi-menu
# pacman -S dialog network-manager-applet networkmanager networkmanager-openvpn
wireless_tools wpa_supplicant wpa_actiond

configure the kernel
# mkinitcpio -p linux
configure the lts kernel
# mkinitcpio -p linux-lts

finish the arch install
# vim /etc/locale.gen
uncomment en_US.UTF-8 UTF-8
# locale-gen
set a root password
# passwd
    enter your password
install and configure grub (the bootloader)
# grub-install --target=i386-pc --recheck /dev/sda
# cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
# grub-mkconfig -o /boot/grub/grub.cfg
create a 2gb swapfile
# fallocate -l 2G /swapfile
# chmod 600 /swapfile
# mkswap /swapfile
# echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
verify swap file in fstab
# cat /etc/fstab

leave the chroot command line
# exit

back in the arch installer, unmount some stuff
ignore the stuff that doesn't unmount
# umount -a

reboot
# poweroff
unplug usb stick
Now it should boot into your arch installation
######################################################

create a user and add a desktop environment

login as root

get an ip
# systemctl start NetworkManager
That should give you an ip? 
confirm you have an ip
# ip a
get NetworkManger to start automatically
# systemctl enable NetworkManger

create a user
# useradd -m bsh
confirm your user
# ls /home
create a password
# passwd jay

install xorg, with is like a desktop environment container
# pacman -S xorg-server
xorg needs a video card driver
find your video card
# lspci
I think I have an intel integrated video card (is it graphics?)
# pacman -S xf86-video-intel libgl mesa

install lightdm, a login manager
# pacman -S lightdm lightdm-gtk-greeter
# systemctl enable lightdm

install mate desktop environment
# pacman -S mate mate-extra

reboot
# reboot
now you can login as bsh

open mate terminal and switch to root
$ su root

install firefox
# pacman -S firefox


##################################################

Install sudo
needed to run commands as a different user so you don't have to switch to root
all the time

$ su root 
# pacman -S sudo

give user accound permission to use sudo
visudo is a command that comes with sudo that lets you edit the config file but
runs a syntax check to make sure you don't make any mistakes
# visudo
here, you can add a user to give permission for sudo use but the preferred way
is to uncommend the line that allows anyone of the group "wheel" to use sudo.
so uncomment that line and then add the user to "wheel"
# usermod -aG wheel bsh
# exit
check that sudo works 
$ sudo ls
you might need to reboot to get it to work

################################################

more about arch

how does pacman work
your computer is subscribed to several online repositories which are servers
that keep an index of available packages. I think these are called mirrors. You
can find the mirror list at /etc/pacman.d/mirrorlist

update your mirror list
It is very common in arch that these mirrors get out of sync. 
So you regularly have to update this mirror list
To update go to archlinux.org/mirrorlist
choose US and check "use mirror status"
that will give you a list or mirrors, ordered by quality
Take 5 or so of those and paste them into your mirrorlist file
delete all the previous ones and make sure to uncomment the new ones
make pacman aware of new mirror list
$ sudo pacman -Syyy

update a package
You should keep it updated every couple weeks because arch updates all the time
and getting out of date can make for difficult troubleshooting
$ sudo pacman -Syu

process management in arch
a process is the same thing as a service or a deamon 
systemd is what manages these background processes
each background process is called a unit
so the terms process, service, or daemon are all just units in systemd
terminology
you will often see the letter d in names. I think that is a historical artifact
and that it stands for deamon
systemctl is the general command for doing things with systemd

install ntp (update system time using the network)
$ sudo pacman -S ntp
like most packagages in arch, if you install something with a unit, that unit
will not be automatically started
check that ntp is inactive
$ systemctl status ntpd
$ sudo systemctl enable ntpd
$ sudo systemctl start ntpd
if you make changes, you can restart with 
$ sudo systemctl restart ntpd

systemd also handles logging
the general command is journalctl
the logs are good for troubleshooting
$ journalctl
to see the logs for the most recent boot
$ journalctl -b
to see the logs for a particular process (in this case, ntp)
$ journalctl -fu ntpd


AUR 
pacman works for almost everything but the aur is an extra package manager for
arch user repositories
the aur includes everything that pacman doesn't, such as google chrome
it is basically a crowdsourced package manager

To use the AUR with yaourt
follow the video from youtube LearnLinux.tv Getting startecd with arch linux
(3rd edition) 12: the aur
He shows how to install chrome

manual intervention update
about 3 to 4 times per year there will be a manual intervention update
you learn about this kind of thing on the latest news on the arch website
you can subscribe to this and have it send to your email so you know how to
keep up with arch





























