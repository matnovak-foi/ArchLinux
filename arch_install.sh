#check signature
gpg --keyserver-options auto-key-retrieve --verify archlinux-version-x86_64.iso.sig

#create bootable usb
dd if=archlinux-2012.08.04-dual.iso of=/dev/sdx bs=4M 
#for some reason needs to be run twice
#if to fast run command
#sync

#restart boot into arch
ls /usr/share/kbd/keymaps/**/*.map.gz # list keyboard layouts
loadkeys croat
ping google.com #check internet

wifimenu #za scan wireless i spajanje na wireless

timedatectl set-ntp true
tidedatectl status

#2. verify boot mode (UEFI or Legacy):
ls /sys/firmware/efi/efivars

#Sync repositories & install latest keyring
pacman -Syy
pacman -S archlinux-keyring

cfdisk #create partions
#dos
#new  -> size -> bootable
#new -> size -> type swap (82)

#UEFI
#GPT
#new -> 500M -> type -> EFI (1)
#new -> size -> type swap (82)
#new -> size -> type linux ext4 root
#new -> size -> type linux ext4 home

lsblk
#mkfs.ext4 /dev/sda1
mkfs.fat -F 32 -n EFI /dev/sda1
mkfs.ext4 -L Root /dev/sda3
mkfs.ext4 -L Home /dev/sda4
#kasnije je složen swap file pa particije neka budu 2 i 3 umjesto 3 i 4
#mkswap /dev/sda2
#swapon /dev/sda2

mount /dev/sda3 /mnt
mkdir /mnt/home
mkdir -p /mnt/boot/EFI
mount /dev/sda1 /mnt/boot/EFI
mount /dev/sda4 /mnt/home

nano /etc/pacman.d/mirrorlist
#leave servers close to you
nano /etc/pacman.conf
#remove # on TotalDownload to see overall download completion 

pacstrap /mnt base linux-lts linux-firmware nano less sudo dhcpcd #instalacija

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

ls /usr/share/zoneinfo
ls /usr/share/zoneinfo/Europem

ln -sf /usr/share/zoneinfo/Europe/Zagreb /etc/localtime

nano /etc/locale.gen #makni komentar koji želiš -> en_US.UTF-8 UTF-8
locale-gen

hwclock --systohc



echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

echo KEYMAP=croat > /etc/vconsole.conf

echo matnovak-Inspiron-5570 > /etc/hostname

nano /etc/hosts
#127.0.0.1	localhost
#::1		localhost
#127.0.1.1	matnovak-Inspiron-5570.localdomain	matnovak-Inspiron-5570


#ovo mislim ne treba
mkinitcpio -P linux-lts

passwd
#enter password for root

useradd -m matnovak -g users #default grupa users
passwd matnovak

usermod -aG wheel,audio,video,optical,storage,lp -s /bin/bash matnovak
#sys,log,network,floppy,scanner,power,rfkill,users,lp,adm

#pacman -S vim
export VISUAL=nano
export EDITOR=nano
visudo
#makni komentar %wheel ALL=(ALL) ALL

systemctl enable dhcpcd

#various systemfile type tools
pacman -S dosfstools os-prober mtools usbutils e2fsprogs reiserfsprogs jfsutils xfsprogs sysfsutils ntfs-3g exfat-utils linux-lts-headers 

#pacman -S 
#grub-install /dev/sda
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --bootloader-id=GRUB-UEFI --recheck #opcija ne treba --efi-directory=/boot/EFI
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo #neznam  dal ovo treba
#ako ne radi probaj sljedeće 
	#mkdir /boot/EFI/BOOT
	#cp /boot/EFI/GRUB/grubx64.efi /boot/EFI/BOOT/BOOTX64.EFI
	#nano /boot/startup.nshb
	#bcf boot add 1 fs0:\EFI\GRUB\grubx64.efi "My GRUB bootloader"
	#exit

sudo nano /etc/default/grub 
#remove quite option to see messages
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S intel-ucode
grub-mkconfig -o /boot/grub/grub.cfg

#ovo je možda bolje nego swap particija
fallocate -l 16G /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
cat /etc/fstab

exit
umount -R /mnt
shutdown now



#kad seugasi makni cdrom van i pokreni
#prijavi se kao matnovak

#-------INSTALL COMPLETE

#provjera boot code nakon instalcije
pacman -S iucode-tool
modprobe cpuid
bsdtar -Oxf /boot/intel-ucode.img | iucode_tool -tb -lS -
grep microcode /proc/cpuinfo

sudo nano /etc/pacman.conf
#makni komentar ispred TotalDownload
#makni komentar na multilib i linija ispod include

sudo pacman -Syyu
sudo pacman -S archlinux-keyring
sudo pacman -Syy
sudo pacman -S reflector
sudo reflector --country 'Croatia' --country 'Slovenia' --country 'Austria' --country 'Germany' --age 15 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
less /etc/pacman.d/mirrorlist

#man_dva_paketa mail diff upravljanje_logom raid_upravljanje which perl i texinfo 
sudo pacman -S man-db man-pages s-nail diffutils logrotate mdadm which perl texinfo 

#iz bivše base grupe nisam instalirao samo za kriptiranje diskova i lvm pariticoniranje
#sudo pacman -S device-mapper cryptsetup  lvm2

sudo pacman -S net-tools
sudo pacman -S xorg xorg-xinit #xterm
sudo pacman -S arandr # da može manual odabir rasporeda ekrana

lspci #ispis moj uređaja zanimljiv onaj pod VGA
#Virtual box
sudo pacman -S virtualbox-guest-utils virtualbox-guest-modules-arch xf86-video-vmware mesa mesa-libgl #mesa neznam dali mi treba
#odaberi 
#for the default linux kernel choose virtualbox-guest-modules-arch
#for non-default kernels choose virtualbox-guest-dkms

sudo pacman -S xf86-video-intel xf86-input-synaptics xf86-video-ati libgl mesa #mesa neznam dal mi treba

sudo reboot

sudo nano /etc/X11/xorg.conf.d/10-evdev.conf
#hrvatska tipkovnica u grafičkom sučelju
Section "InputClass"
    Identifier "evdev keyboard catchall"
    MatchIsKeyboard "on" #device types
    MatchDevicePath "/dev/input/event*" #This entry can be used to check if the device file matches the "matchdevice" pathname pattern.
    Driver "evdev" #Generic Linux input driver
    Option "XkbLayout" "hr" #Keyboad layout
EndSection

#KDE
	#https://www.youtube.com/watch?v=lv5CyzsIjJk
	sudo pacman -S plasma konsole dolphin #kod opcija 1 opcija gstreamer odabrati
	sudo pacman -S plasma-desktop #minimalistička opcija
	
	#Essential packages for the cohesion in look between GTK and KDE applications:
	sudo pacman -S breeze-gtk breeze-kde4 kde-gtk-config 
	#Enable Breeze theme in SDDM:
	nano /etc/sddm.conf
	
	#And in the section Theme, add Current=breeze.
	#Install additional plasma widgets and plugins:
	sudo pacman -S kdeplasma-addons
	sudo systemctl enable sddm
	sudo pacman -S networkmanager plasma-nm openvpn networkmanager-openvpn
	cp /etc/X11/xinit/xinitrc ~/.xinitrc #ovo ne treba
	
	echo "exec startplasma-x11" >> ~/.xinitrc
	#add na kraj exec startplasma-x11
	sudo pacman -Rs discover

	3. Enable audio volume control.

	You need to have PulseAudio and GStreamer Multimedia Framework installed. See these videos for details:
	https://youtu.be/GKdPSGb9f5s?t=6m52s -  PulseAudio
	https://youtu.be/jW4GFGOIUjc?t=1m42s -  GStreamer

	sudo pacman -S plasma-pa

	Restart your Plasma 5 by log out and log in. And you have a volume control on your panel.


#mreža i wireless
sudo pacman -S networkmanager network-manager-applet wireless_tools wpa_supplicant dialog inetutils netctl

#Disable dhcpcd:
sudo systemctl stop dhcpcd
sudo systemctl disable dhcpcd

#Enable Networkmanager:
#Then enable NetworkManager:
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

sudo pacman -S openvpn networkmanager-openvpn

sudo pacman -Syy
sudo pacman -Su

#I3 window manager
	sudo pacman -S ttf-dejavu ttf-droid ttf-inconsolata 
	sudo pacman -S i3 dmenu
	sudo pacman -S perl-json-xs perl-anyevent-i3
	#select 1 3 4 5
	echo "exec i3" >> .xinitrc

#MATE
	sudo pacman -S mate #not caja
	sudo pacman -S mate-extra
	#1 8 9 10 11 13 14 15 16 17 18 19 20 21 22
	sudo pacman -S terminator nemo geany
	echo "exec mate-session" >> .xinitrc


#zvuk
sudo pacman -S alsa-utils alsa-oss

sudo pacman -S --needed base-devel git

sudo nano /etc/makepkg.conf
#change MAKEFLAGS="-j2"
#to     MAKEFLAGS="-j$(nproc)"


git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay -Ss brave
yay -S brave-bin
	#git clone https://aur.archlinux.org/brave-bin.git 
	#cd brave-bin
	#less PKGBUILD
	#makepkg -si
	
#THEME
sudo pacman -S gtk-update-icon-cache
sudo pacman -S gtk-engine-murrine 
yay -S numix-gtk-theme-git
yay -S numix-icon-theme-git
yay -S numix-circle-icon-theme-git
yay -S numix-folders-git
#sudo /usr/bin/numix-folders

#copy displayselection to bin
nano .bashrc
#add export PATH=$PATH:/home/matnovak/bin

yay -S mate-tweak-git
yay -S timeshift
yay -S luckybackup
yay -S viber
yay -S skypeforlinux-stable-bin
yay -S dropbox #first option
yay -S rstudio-bin
yay -S udunits #needed for r for some statistical calculations for package pgirmess
yay -S mendeleydesktop-bundled

sudo pacman -S lsscsi lsb-release
sudo pacman -S cifs-utils  #to be able to mount NAS with cifs, requires reboot
sudo pacman -S vlc thunderbird keepassxc htop subversion neofetch 
sudo pacman -S most #color in manual
sudo pacman -S python-pygments pygmentize #for even more color in terminal with less 
sudo pacman -S libreoffice-still
sudo pacman -S bash-completion
sudo pacman -S lynx #terminal browser
sudo pacman -S cmatrix
sudo pacman -S ttf-ubuntu-font-family ttf-dejavu ttf-droid ttf-inconsolata ttf-roboto ttf-opensans ttf-bitstream-vera ttf-liberation
sudo pacman -S wget
sudo pacman -S simplescreenrecorder
sudo pacman -S gimp 
sudo pacman -S hardinfo
sudo pacman -S ufw gufw
sudo pacman -S texlive-most texlive-langcyrillic texlive-langgreek texlive-langextra
sudo pacman -S texstudio
sudo pacman -S r gcc-fortran tk gdal
sudo pacman -S firefox
sudo pacman -S netbeans 
sudo pacman -S tomcat8
sudo gpasswd -a matnovak tomcat8 
#tomcat9 extract tar.gz to /opt

#copy fstab za druga dva diskasx

#PRINT
	sudo pacman -S cups cups-pdf system-config-printer ghostscript gsfonts foomatic-db foomatic-db-engine  #print
	yay -S epson-inkjet-printer-escpr #za epson L3060
	yay -S samsung-m262x-m282x #za samsung M283x
	yay -S capt-src #za doma LBP 3010 printer
		sudo gpasswd -a matnovak lp #nakon install
		lpadmin -p LBP3010 -m CNCUPSLBP3050CAPTK.ppd -v ccp://localhost:59687 -E
		systemctl restart org.cups.cupsd.service
		systemctl enable org.cups.cupsd.service
		ccpdadmin -p LBP3010 -o /dev/usb/lp1
		#provjeri usb prort nakon spajanja
		#ls -al /dev/usb
		#provjeri poruke sa 
		#dmesg | grep -i usb
		#ili sa lsusb vidi dal ima ga prepoznatog
		#lsusb
		#ako se ne vidi problem je sa kablom
		systemctl start ccpd.service
		systemctl enable ccpd.service
		captstatusui -P LBP3010
		
	sudo nano /etc/cups/cups-pdf.conf
	#change OUT option to
	Out /home/matnovak/cups-pdf/
	
	systemctl enable org.cups.cupsd.service

sudo gpasswd -a matnovak adm

#scaner
	sudo pacman -S simple-scan 	imagescan 
	yay -S imagescan-plugin-networkscan
	sudo nano /etc/utsushi/utsushi.conf 
	#add
	[devices]

	myscanner.udi    = esci:networkscan://192.168.1.107
	myscanner.vendor = Epson
	; myscanner.model  = DS-5500
	myscanner.name = Epson-Scanner-Ured

	utsushi

#za hibernate RAM = SWAP, a ako ne trebam onda 25% RAM za memoriju veća od 4GB ili 50% za manje od 4GB
#swappines information
cat /proc/sys/vm/swappiness
#change swap 
echo 10 > /proc/sys/vm/swappiness
sysctl vm.swappiness=10	
sudo nano /etc/sysctl.d/99-swappiness.conf

#hibernate activation
	lsblk -f #da saznaš UUID root particije di je /swapfile UUID=4cf2902d-1df5-447a-8a8c-49bebae24f95
	lsblk #da saznaš MAJ:MIN on je 259:2
	filefrag -v /swapfile | awk '{ if($1=="0:"){print $4} }' #da saznaš resume offset
	#ili samo filefrag -v /swapfile i traži physical broj kod reda 0

	echo 259:2 > /sys/power/resume
	echo 284672 > /sys/power/resume_offset

	nano /etc/default/grub
	GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 resume=UUID=4cf2902d-1df5-447a-8a8c-49bebae24f95 resume_offset=284672"
	grub-mkconfig -o /boot/grub/grub.cfg

	nano /etc/mkinitcpio.conf
	#add the resume module hook 
	HOOKS="base udev resume autodetect ..."
	mkinitcpio -p linux-lts
	systemctl hibernate 

#enable cron
sudo systemctl enable cronie.service
sudo systemctl start cronie.service


#ssh no password - http://rabexc.org/posts/using-ssh-agent

	#SSH public key authentication
	# Generate a key pair
	# Do NOT leave the passphrase empty
	ssh-keygen
	# Copy it to the remote host (added to .ssh/authorized_keys) - repeat for every server
	ssh-copy-id user@host

	#Setup the SSH authentication agent
	# Start the agent
	eval `ssh-agent`
	# Add the identity (private key) to the agent
	ssh-add /path/to/private-key
	ssh-add ~/.ssh/id_rsa
	# Enter key passphrase (one time only, while the agent is running)

	#Connect as usual
	ssh user@host

	#change passpharse
	cd .ssh
	ssh-keygen -f id_rsa -p
	
	#to run ssh only once look at .bashrc

#POTENCIJALNI OSTALI

E. install software

pacman -Sy xorg-drivers xorg-xkill mesa #(za igre)

#https://erikdubois.be/how-to-install-arch-linux/ a sjruote su ovdje https://github.com/erikdubois/archi3
#https://github.com/LukeSmithxyz/voidrice/tree/master/.local/bin # dnenu scripts
General
pacman -Sy --needed dkms p7zip archiso haveged pacman-contrib pkgfile  btrfs-progs f2fs-tools sdparm sg3_utils smartmontools   gvfs-afc gvfs-goa gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb unrar unzip unace xz xdg-user-dirs xscreensaver grsync ddrescue dd_rescue testdisk hdparm     polkit bleachbit
#installed automatically fuse2 fuse3 gvfs unzip
Multimedia
pacman -Sy --needed pulseaudio cdrtools gstreamer gst-libav gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad gst-plugins-ugly gstreamer-vaapi gst-transcoder xvidcore frei0r-plugins cdrdao dvdauthor transcode alsa-plugins alsa-firmware pulseaudio-alsa pulseaudio-equalizer pulseaudio-jack ffmpeg ffmpegthumbnailer libdvdcss guvcview imagemagick flac faad2 faac mjpegtools x265 x264 lame sox mencoder

Networking
pacman -Sy --needed b43-fwcutter broadcom-wl-dkms ipw2100-fw ipw2200-fw net-tools nm-connection-editor firefox nfs-utils nilfs-utils dhclient dnsmasq dmraid dnsutils openssh openssl samba whois iwd filezilla avahi openresolv youtube-dl vsftpd 

Fonts & Themespa
pacman -Sy --needed  noto-fonts  opendesktop-fonts papirus-icon-theme

Printing
pacman -Sy --needed  gutenprint hplip cups-pk-helper pyqt5-common python-pillow python-pyqt5 python-pip python-reportlab

Mate Desktop
pacman -Sy --needed  sddm gparted transmission-gtk brasero asunder quodlibet pitivi gnome-disk-utility mate-polkit gnome-packagekit

F. enable services
systemctl enable sddm.service


#mentaince pacman
pacman -Qdt #list orphan packages
pacman -Rsn $(pacman -Qdtq)
