## arch/i3 installation 

### Prepare usb stick

download arch iso 
show your drives
```
$ lsblk
```
plug in your usb stick and show your drives again, remember the name of the usb stick
```
$ lsblk
```
change user to root
```
$ su root
```
then use dd (knowwn as disk destroyer) to put the iso on the usb stick
```
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

or if you need to connect with ethernet
find your network card name
# ip a
It will be something like enp0s3
# cp /etc/netctl/examples/ethernet-dhcp /etc/netctl/enp0s3

edit this file so that "interface=enp0s3"
# sudo vim /etc/netctl/enp0s3
then reboot


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
# pacman -S i3-wm i3blocks i3lock rxvt-unicode dmenu perl-anyevent-i3 perl-json-xs 
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
then reboot

a bunch more installs 
$ sudo pacman -S xcape firefox git ranger gvim 

git clone your dotfiles repo
move your dotfiles into the home directory

enable copy and paste
move .vimrc and .vim folder into place 

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
$ cd urxvt-resize-font-git
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

if you need to change timezone
check current timezone 
$ timedatectl status
list available timezones 
$ timedatectl list-timezones
change timezone (eg America/Los_Angeles or America/Denver)
$ timedatectl set-timezone Zone/SubZone

#########################################

more about arch

update your mirror list
It is very common in arch that these mirrors get out of sync. 
So you regularly have to update this mirror list
To update go to archlinux.org/mirrorlist
choose US and check "use mirror status"
that will give you a list or mirrors, ordered by quality
Take 5 or so of those and paste them into your mirrorlist file located at /etc/pacman.d/mirrorlist
delete all the previous ones and make sure to uncomment the new ones
make pacman aware of new mirror list
```
$ sudo pacman -Syyy
```

update a package
You should keep it updated every couple weeks because arch updates all the time
and getting out of date can make for difficult troubleshooting
```
$ sudo pacman -Syu
```
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
it is basically a crowd sourced package manager

manual intervention update
about 3 times per year there will be a manual intervention update
you learn about this kind of thing on the latest news on the arch website
you can subscribe to this and have it send to your email so you know how to
keep up with arch





























