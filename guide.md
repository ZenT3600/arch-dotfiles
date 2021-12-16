\pagenumbering{gobble}

# Arch Linux Suckless Installation And Configuration Guide For UEFI Systems
> Matteo Leggio, Jul 2021

\vspace{2cm}

\LARGE
```
                   -`
                  .o+`
                 `ooo/
                `+oooo:
               `+oooooo:
               -+oooooo+:
             `/:-:++oooo+:
            `/++++/+++++++:
           `/++++++++++++++:
          `/+++ooooooooooooo/`
         ./ooosssso++osssssso+`
        .oossssso-````/ossssss+`
       -osssssso.      :ssssssso.
      :osssssss/        osssso+++.
     /ossssssss/        +ssssooo/-
   `/ossssso+/:-        -:/+osssso+-
  `+sso+:-`                 `.-/+oso:
 `++:.                           `-/+/
 .`                                 `/
```
\normalsize

\pagebreak

\tableofcontents

\pagebreak

\pagenumbering{arabic}

## Installation Steps

### 1. Pre-Installation

Get an USB pendrive and flash it with the latest live iso found on the [Arch Linux](https://archlinux.org/) website.

Assuming your starting OS is Windows, you can use BalenaEtcher to flash the pendrive.

Once the flashing process is complete -still assuming a Windows OS- press the windows key, then press on the power option and press "Restart" while holding down Shift on your keyboard.

Upon restarting you will be prompted with a light-blue screen. Select the "Use a Device" option and choose the flashed pendrive.

You will then be prompted with a screen with the Arch logo on it and a few options. Select the "Arch Linux install medium" one and let the thing run until you're greeted with a root shell.

Congratulations, you just logged into an Arch Live USB.

To make things a little easier, switch your keyboard layout using `loadkeys` followed by your language. For example, my command looks like `loadkeys it`.

### 2. Partitioning

First of all, to install Arch Linux you have to find a disk/pendrive to install the OS on. To do so, run the `fdisk -l` command. This will list all your available disks. For this guide I will use a 28G pendrive, and my device path is `/dev/sdb`. Your path will look very much the same: A slash, followed by "dev", followed by another slash, to end with "sd" and another letter.

Once you've found the device you want to install Arch on, run `fdisk` and pass it your device path as the first argument. My command looks like `fdisk /dev/sdb`.

Do keep in mind that the following commands will empty the selected disk's data, so be sure to have a backup.

This command will throw you into another shell. Once you're there, type the following:

* d (To remove 1 partition from the device. Run this until the device has no more partitions)
* n (To create a new partition. This will be the swap partition)
	* \<Enter> x 3 (To select the first 3 default options)
	* "+512M" (To describe the size of the partition)
* t (To change the last partition type)
	* l (To list all the possible types and their IDs. Find the ID related to the "EFI" partition type)
	* "ef" (Replace this with the "EFI" partition type ID)
* n (To create a new partition. This will be the root partition)
	* \<Enter> x 4 (To select all the default options)
* w (To write the change)

By doing that you have successfully created the needed partitions and have been dropped back into a regular shell.

Now the partitions need to be assigned a filesystem. Assuming your device is "/dev/sdb", type `mkfs.fat -F32 /dev/sdb1` to make the swap partition a FAT32 filesystem, then type `mkfs.ext4 /dev/sdb2` to make the root partition an EXT4 filesystem.

### 3. Internet Connection

To keep going with the installation process you will need to be connected to the internet. To do so, first figure out your WLAN interface name, then type `iwctl`. This will bring you into an interactive shell. Inside of it, assuming your WLAN interface name is "wlo0" and your Wifi name is "Wifi", type `station wlo0 connect "Wifi"`, or `station wlo0 connect-hidden "Wifi"` if your Wifi is hidden. Then, if needed, type your wifi password. Once you're done, type `exit` to go back to a regular shell.

To check that you're actually connected to the internet, try pinging Google with `ping www.google.com`. If your pings get back to you, then you are connected. Press CTRL+C to stop pinging and keep on installing.

Now that you're connected to the internet, update the package repositories with `pacman -Syy`.

After that, install "reflector" with `pacman -S reflector`. Reflector will help you find pacman mirrors near your country. To use reflector, first backup the current pacman mirrorlist with `cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak`, then run `reflector -c "IT" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist` replacing "IT" with your country code.

### 4. Setting Up Arch

Now we can finally start setting up Arch itself. First, assuming a "/dev/sdb" device, run `mount /dev/sdb2 /mnt` to load the root partition on the device on the "/mnt" folder.

Once you've done that, run `pacstrap /mnt base linux linux-firmware vim wpa_supplicant networkmanager` to install the bare needed packages, alongside with arch itself, on the "/mnt" folder, which is noneother than the device's root partition itself. Now step back and relax, because this will take a while.

Once that command is done, run `genfstab -U /mnt >> /mnt/etc/fstab` to generate an fstab file that will dictate how mounted devices are handled.

At this point, you can safely login into your Arch install, even though it's not yet completely ready. To do so, type `arch-chroot /mnt`.

Once you're inside the new shell, update your clock with `timedatectl set-timezone Europe/Rome` replacing "Europe/Rome" with your country and city.

Next, to generate the locales, edit the "locale.gen" file with `vim /etc/locale.gen` and uncomment the line with your chose language, for example "en\_GB.UTF-8", write the changes and then run `locale-gen` to apply said changes. After that, run `echo LANG=en_GB.UTF-8 > /etc/locale.conf && export LANG=en_GB.UTF-8` replacing "en\_GB.UTF-8" with the language you chose before.

After this, set your computer's hostname by typing `echo your-hostname > /etc/hostname` and replacing "your-hostname" with a name of your choice. Then, type `touch /etc/hosts` and then `vim /etc/hosts`. At the end of the file, add the following:

```
127.0.0.1	localhost
::1		localhost
127.0.0.1	your-hostname
```

Replace "your-hostname" with the hostname you chose before.

Before going further, remember to type `systemctl enable NetworkManager.service` to enable the service used to connect to the internet.

Now let's talk users. Type `passwd` to change the "root" user's password. After that, to create a sudoer user, so that you don't have to always use "root", type `useradd -g wheel -m name` and `passwd name` and replace "name" with a name of your choice to create a new user and change its password.

As of now "sudo" is not installed, so the user you just created can't actually run commands as "root". To enable it to do so, install "sudo" with `pacman -S sudo` and then edit the sudoers file with `vim /etc/sudoers` and uncomment the line that says "%wheel ALL=(ALL) ALL".

### 5. Bootloader

We're almost done. Now let's install the GRUB bootloader by running `pacman -S grub efibootmgr`. After that, create the "/boot/efi" directory with `mkdir /boot/efi` and then mount the swap partition of your device on it with `mount /dev/sdb1 /boot/efi` (Assuming your device is "/dev/sdb").

Then, to actually setup the bootloader, run `grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi` and then `grub-mkconfig -o /boot/grub/grub.cfg`

### 6. Desktop Enviroment

At this point the base system is fully installed. The only thing that's left is the Desktop Enviroment. To install it, first log into the sudoer user you just created with `su name` and go to its home with `cd`.

Once you're there, type `sudo pacman -S xorg xorg-server xorg-init base_devel git libx11 libxinerama libxft webkit2gtk` to install all the needed dependencies.

After that, clone down the needed repos with `git clone https://git.suckless.org/dwm` and `git clone https://git.suckless.org/st`. These are both your desktop enviroment and your terminal.

Since these are suckless programs, you have to compile them. To do so, go into each directory with `cd dwm` or `cd st`, run `sudo make clean install` to install it and the go back with `cd`. Once you've compiled both the programs, go back to your home directory.

To automatically start your DE at startup, edit your ".xinitrc" file with `vim .xinitrc` and add "exec dwm" in it, then edit your ".bash\_profile" file with `vim .bash_profile" and append "startx" at the end of the file,

### 7. Post-Installation

Now you're officialy done installing Arch Linux, good job. To start your system, first go back to the Live USB by typing `exit` twice, then type `shutdown now` to turn your computer off.

Once the computer is off, take your Live USB out of it and start it up again. If you end up booting into Windows, repeat the first Pre-Installation steps and boot into the device you installed Arch on.

You will be greeted with a screen with a few choices. Select "Arch Linux".

The system will boot. Once it's done, enter your sudoer user credentials. If everything goes right, you will be greeted with the DWM Desktop Enviroment.

Congratulations, you have successfully installed Arch!

\pagebreak

## Configuration Tips

### 1. Useful Programs

Images/Videos:

* feh 
	* `sudo pacman -S feh`
	* For settings backgrounds
		* `feh --bg-fill /path/to/file.ext`
* sxiv 
	* `sudo pacman -S sxiv`
	* For viewing Images/GIFs
		* `sxiv /path/to/file.ext`
* pywal
	* `sudo pacman -S imagemagick`
	* `sudo python3 -m pip install pywal`
	* For generating color schemes
		* `wal -i /path/to/image`
	* Requires LukeSmith's fork of ST (See "Configuring Suckless Programs" category)
	* Do keep in mind that colors other than ST's, such as DWM, Herbe and so on, need to be changed in the source code.

* mpv
	* `sudo pacman -S mpv`
	* For viewing Videos/Audios
		* `mpv /path/to/file.ext`
		* `mpv /path/to/device` (Works with Video Devices like "/dev/videoX")
	* Requires audio drivers to be installed (See "Audio Drivers" category)

Documents:

* zathura
	* `sudo pacman -S zathura`
	* For viewing text documents
		* `zathura /path/to/file.ext`
	* Needs plugins for various file types

* pandoc
	* `sudo pacman -S pandoc texlive-most`
	* For creating PDF documents from MD files
		* `pandoc /path/to/file.md -o /path/to/file.pdf`

Web:

* surf
	* `git clone https://git.suckless.org/surf && cd surf && sudo make clean install`
	* For navigating through simple webpages
		* `surf hostname`
	* Very slow
	* Suckless

Utilities:

* herbe
	* `git clone https://github.com/dudik/herbe && cd herbe && sudo make clean install`
	* For showing notifications on the X-Server
		* `herbe "Line 1" "Line 2" "Line 3 and so on"`

* picom
	* `sudo pacman -S picom`
	* For adding post-processing to windows
		* `picom --config /path/to/file.conf &`
	* Patch to avoid conflicts with DWM
		* File: "/etc/xdg/picom.conf"
		* `focus-exclude = "x = 0 && y = 0 && override_redirect = true";`
	* Patch to work with ST
		* URL: https://st.suckless.org/patches/alpha/
		* `patch -p1 < st-alpha.diff`

* handlr
	* `git clone https://aur.archlinux.org/handlr.git && cd handlr && makepkg -si`
	* Better version of `xdg-open`
		* Change `xdg-open` for `handlr open` with:
			* `sudo rm /usr/bin/xdg-open`
			* `sudo vim /usr/bin/xdg-open`
			* `""" handlr open "$@" """`
			* `sudo chmod +x /usr/bin/xdg-open`
	* Requires ".config/mimeapps.list" to be configured, see "DotFiles" category

* nnn
	* `sudo pacman -S nnn`
	* CLI file manager
	* See "DotFiles" category for configuration

* slock
	* `sudo pacman -S xautolock`
	* `git clone https://git.suckless.org/slock && cd slock && sudo make clean install`
	* For locking the computer after a certain ammount of time (See the "DotFiles" category for configuration)

* ly
	* `git clone https://github.com/nullgemm/ly && cd ly && sudo make github && sudo make && sudo make install && sudo systemctl enable ly.service`
	* `vim /etc/ly/config.ini`
		* \* uncomment every instruction *
	* Display / Login manager

* other suckless utilities
	* https://suckless.org/

### 2. Audio Drivers

Alsa Audio Drivers:

1. `sudo pacman -S alsa-utils`
2. `alsamixer`
3. \* Adjust Master Mixer *
4. `alsactl --file ~/.config/asound.state store`

### 3. Remote Connections

SSH Connection:

* Server-Side:
	1. `systemctl enable sshd`
	2. `systemctl start sshd`
	3. Get IP Through `ip route get 1.2.3.4 | awk '{print $7}'`

* Client-Side
	1. `ssh user@ip`

### 4. DotFiles

#### 4.1. .xinitrc

```bash
#!/usr/bin/bash

### Restore Audio Driver's Settings
alsactl --file ~/.config/asound.state restore

### Setup Desktop Enviroment's Settings
wal -i ~/bgs/ --saturate 0.75

### Add Data To DWM
# Get the current temperature
curl -s wttr.in | awk '{$1=$1};1' | grep '°C' | head -n 1 | \
awk -F " " '{print $(NF-1)" "$NF}' | sed "s,\x1B\[[0-9;]*m,,g" > .wttr.in

bardate() {
	echo -e "$(date)"
}

barip() {
	echo -e "$(ip route get 1.2.3.4 | awk '{print $7}')"
}

barbattery() {
	echo -e "$(cat /sys/class/power_supply/BAT1/capacity)%"
}

bartemp() {
	cat ~/.wttr.in
}

while true; do
	xsetroot -name " $(barbattery) | $(barip) | $(bartemp) | $(bardate) "
	sleep 1
done &

### Start Desktop Enviroment
picom &
xautolock -time 30 -locker slock &
exec dwm
```

---

#### 4.2. .bash\_profile

```bash
#!/usr/bin/bash

if [[ -n "$SSH_CONNECTION" ]]; then
	# It's a Remote Connection through SSH, no need to start the X-Server
	sleep 0
else
	# It's a Local Connection, start the X-Server
	startx
fi
```

---

#### 4.3. .bashrc

```bash
#!/usr/bin/bash

### DWM Info
# Get the current temperature
curl -s wttr.in | awk '{$1=$1};1' | grep '°C' | head -n 1 | \
awk -F " " '{print $(NF-1)" "$NF}' | sed "s,\x1B\[[0-9;]*m,,g" > .wttr.in

### PyWal
(cat ~/.cache/wal/sequences &)
source ~/.cache/wal/colors-tty.sh

### Aliases
alias cat="bat"
alias _cat="/usr/bin/cat"
alias la="ls -la"
alias ls="ls -l --color=auto"

### nnn
export NNN_SSHFS="sshfs -o follow_symlinks"
export NNN_TRASH=1

### Set your preferred keymap
setxkbmap it

### Add a prompt
PS1='[\u@\h \W]$ '
[ -n "$NNNLVL" ] && PS1="N$NNNLVL $PS1"

### Notify SSH Connections
if [[ -n $SSH_CONNECTION ]]; then
	IP=$(echo $SSH_CONNECTION | awk '{print $1}')

	# Run notification asynchronously on the X-Server
	DISPLAY=":0" herbe "Accepted SSH Connection From IP $IP" &
fi
```

---

#### 4.4. .config/mimeapps.list

```yaml
[Default Applications]
image/jpeg=sxiv.desktop
image/bpm=sxiv.desktop
image/webm=sxiv.desktop
image/gif=sxiv.desktop
image/png=sxiv.desktop
audio/mpeg=mpv.desktop
audio/x-mp3=mpv.desktop
audio/aac=mpv.desktop
audio/ogg=mpv.desktop
audio/opus=mpv.desktop
audio/wav=mpv.desktop
audio/webm=mpv.desktop
video/x-msvideo=mpv.desktop
video/mp4=mpv.desktop
video/mpeg=mpv.desktop
video/ogg=mpv.desktop
video/webm=mpv.desktop
```

---

#### 4.5. .config/picom.conf

```toml
// ...

shadow = false;
fading = false;
blur-background = false;
opacity-rule = [
	"90:class_g = 'URxvt' && focused",
	"60:class_g = 'URxvt' && !focused"
];

// ...
```

### 5. Configuring Suckless Programs

Suckless programs are programs developed withouth configuration files. You have to modify and compile the program yourself, while the program has no need to read external files, therefore removing bloat.

Most of the programs mentioned in this guide are suckless programs, so I'm going to explain how to configure said programs in this section.

#### 5.1. Common config.h

\hfill

This line is common in most config.h files, and is used to modify the font that the program is using.

```c++
static char *font = "fontface:size=fontsize";
```

Replace `fontface` with a font (you can get fonts with the `fc-list` command) and `fontsize` with the size of the font.

This line may differ between various suckless programs, but most of them usually have a line similar to this one, which defines the colors the program will be using.

```c++
static const char *colors[] = {
	// ... Various colors ...
}
```

Colors are supplied with their HEX values.

#### 5.2. st/config.h

\hfill

Simple Terminal's (st) config.h file has no need to be modified if not for colors, modifiable with the value described in the "Common config.h" category, and the shell value, which looks like:

```c++
static char *shell = "/bin/sh";
```

Change `"/bin/sh"` to the path of a different shell to change the startup shell.

LukeSmithxyz's GitHub offers a fork of ST with a few major improvements to the program itself. It adds the ability to scroll, zoom and change colors dynamically. To get the fork, run `git clone https://github.com/LukeSmithxyz/st luke-st && cd luke-st && sudo make clean install`

Other than adding features, this fork also changes a few keyboard shortcuts. Most notable are Ctrl+Shift+C and Ctrl+Shift+V becoming Alt+C and Alt+V and zooming becoming Alt+Shift+J and Alt+Shift+K.

#### 5.3. dwm/config.h

\hfill

To modify DWM's size factor of master-slave windows, you can modify the following line.

```c++
static const float nfact = 0.55;
```

The larger the number, the larger the master window compared to its slaves windows.

If you want to add a keyboard shortcut to start a program, you first need to add a line that looks like this:

```c++
static const char *programcmd = { "program", "param1", "param2", NULL };
```

And the add the following line inside of the `static Key keys[]` variable.

```c++
{ MODKEY|ShiftMask, XK_letter, spawn, {.v = programcmd } },
```

And replace the `XK_letter` constant with an actually valid constant.

If you don't want to start a regular program but instead want to start a command in a new terminal window, then you can do so by changing `*programcmd` to the following.

```c++
static const char *programcmd = { "st", "-e", "sh", "-c", "command", NULL };
```

It's also possible to wrap this line in a script like so.

```bash
# File: /usr/bin/open-in-new-terminal

st -e sh -c "$(echo ${@// / }) && exit"
```

And then change `*programcmd` to look like this.

```c++
static const char *programcmd = { "open-in-new-terminal", "command", "args", NULL }
```

This approach allows the use of arguments that will be passed to the command.

#### 5.4. herbe/config.h

\hfill

Herbe's conig.h file mostly consists of purely decorative instructions.

You can modify the base duration of the herbe notification by modifying the following line.

```c++
static const unsigned int duration = 5;
```

And you can also modify the corner the notification will show up on by changing the following line with one of the values from the `corners` enumerate.

```c++
enum corners corner = TOP_RIGHT;
```

#### 5.5. slock/config.h

\hfill

Slock's config.h file needs to be modified before building the program, as it contains the user and group that needs to be authenticated when the lock is executed.

To edit in your user and group, modify the following lines with your info.

```c++
static const char *user  = "user";
static const char *group = "group";
```

#### 5.6. Community-Made Patches

\hfill

The suckless.org website offers community-made patches under the "/patches" category of each of their utilities. These patches consist of git diff files, and the patching process won't always be successful, as different patches can conflict with each other.

To apply a patch automatically, use `patch -p1 < patch-file.diff` while inside of the program's directory.

To apply a patch manually, using the cues given in the diff file, add every line that starts with a "+" in the specified file and remove any line that starts with a "-". The lines that don't start with a "+" or a "-" can be used as a landmark to navigate through the actual file.

### 6. Managing Private Repos

#### 6.1. Creating the Repos

\hfill

Setting up a private github repo to hold your tools and dotfiles is always a good idea; you never know when your system will crash and corrupt itself permanently. DotFiles and Tools repos are a way to easily recover from situations like the one I described.

Here's how to do it:

* Create a private github repo

* On the local machine, add whatever files you need to store into a directory named like the repo (I suggest a directory tree consisting of README and Install Script on the root directory of the repo and actual files in a subdirectory)

* Add a README.md file and write an Install Script (More on Install Scripts in "Install Scripts" category)

* `git init`

* `git add .`

* `git commit -m "Initial Commit"`

* `git branch -M main`

* `git remote add origin <GitUrl>`

* `git push -u origin main`

#### 6.2. Install Scripts

\hfill

Install Scripts are an easy way to apply the files that were cloned alongside the github repo. An install script should be short and simple, with, if possible, no user interaction required. You should be able to run the script, maybe give your sudo password if needed, and just sit back and relax.

Here's a few examples of Install Scripts:

```bash
# File: DotFiles install.sh

ls -a dotfiles | xargs -I {} sh -c "ln -s $PWD/dotfiles/{} ~/{} &> /dev/null \n
&& echo \"Linked {}\" || echo \"Skipping {}\""
```

---

```bash
# File: Tools install.sh

for tool in $(ls -d */); do
        cd $tool
        if [[ -f config.h || -f config.def.h ]]; then
                echo "Installing $tool"
                sudo make install > /dev/null
                echo "Successfully installed $tool"
        else
                echo "$tool Doesn't require installation"
        fi
        cd ..
done
```
