## Configure

### Console and SSH

With [USB OTG](https://en.wikipedia.org/wiki/USB_On-The-Go) enabled, an USB keyboard can be connected to interact with the login prompt. This implies editing the */etc/shadow* file on the SD card from another machine beforehand, in order to set the root password.

Alternatively, this minimal Debian system run a SSH server. If connected to a USB host, a USB ethernet network adapter is brought up at boot with IP 192.168.234.2. By setting IP 192.168.234.1 on the host, the Debian smartphone answers to ping. Before connecting over SSH, either a user and password must be added in the SD card from another machine, or the public SSH key of the host must be copied to */root/.ssh/authorized_keys*.

```
$ ssh root@192.168.234.2

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
root@grandprime:~#
```

Welcome to Debian on your phone!

By enabling IP forwarding and masquerading on the host, the phone can connect to internet, which will be needed to install more packages.

### User permissions

The Android kernel with *CONFIG_ANDROID_PARANOID_NETWORK* requires users to be added to groups with predefined GIDs in order to access network. First let's create those groups:

```
$ groupadd -g 3001 aid_bt
$ groupadd -g 3002 aid_bt_net
$ groupadd -g 3003 aid_inet
$ groupadd -g 3004 aid_net_raw
$ groupadd -g 3005 aid_admin
```

Then add *root* to those groups:

```
$ usermod -aG aid_bt,aid_bt_net,aid_inet,aid_net_raw,aid_admin root
```

A normal user is added with:

```
$ adduser deb 
Adding user `deb' ...
Adding new group `deb' (1001) ...
Adding new user `deb' (1001) with group `deb' ...
Creating home directory `/home/deb' ...
Copying files from `/etc/skel' ...
Enter new UNIX password: 
...
```

Just like for *root*, this user needs to be added to the network permission groups:

```
$ usermod -aG aid_bt,aid_bt_net,aid_inet,aid_net_raw,aid_admin deb
```

### Packages

To install packages with *apt*, the user *_apt* needs some of the network permissions:

```
$ usermod -G nogroup -g aid_inet _apt
```

The system is now ready to install more software packages through network. For example to install *sudo*:

```
$ apt update
Hit:1 http://deb.debian.org/debian buster InRelease
Reading package lists... Done
Building dependency tree... Done
All packages are up to date.
$ apt install sudo
...
```

Finally, to allow *sudo* without password:

```
$ echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```

### Docker

The complete instructions to install [Docker](https://www.docker.com/) on Debian are [here](https://docs.docker.com/engine/install/debian/). In our case it is:

```
$ apt install apt-transport-https curl gnupg
$ curl -kfsSL https://download.docker.com/linux/debian/gpg | apt-key add -
```

Then in */etc/apt/sources.list* add:

```
deb [arch=armhf] https://download.docker.com/linux/debian buster stable

```

As overlay is not available, [VFS](https://docs.docker.com/storage/storagedriver/vfs-driver/) can be use for storage. Create the file */etc/docker/daemon.json* with:

```
{
  "storage-driver": "vfs"
}
```

To install Docker:

```
$ apt update
$ apt install docker-ce
```

Docker will not start unless iptables is set to legacy mode (select 1 in the menu):

```
$ update-alternatives --config iptables
```

Now let's restart it and check it is working:

```
$ systemctl restart docker
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
$ docker run -it --rm hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
4ee5c797bcd7: Pull complete 
Digest: sha256:8e3114318a995a1ee497790535e7b88365222a21771ae7e53687ad76563e8e76
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
...

$ docker run -it --rm busybox
Unable to find image 'busybox:latest' locally
latest: Pulling from library/busybox
47a9f0637952: Pull complete 
Digest: sha256:a8cf7ff6367c2afa2a90acd081b484cbded349a7076e7bdf37a05279f276bc12
Status: Downloaded newer image for busybox:latest
/ # busybox 
BusyBox v1.31.1 (2020-04-13 23:06:12 UTC) multi-call binary.
...
```

### Wi-Fi

Wi-Fi requires binary firmware files. They must be extracted over from an original system or a backup and copied to *src/overlay/sdcard/lib/firmware/*. With the smartphone used as reference, those files are:
* mrvl/bt_init_cfg.conf
* mrvl/SDIO8777_SDIO_SDIO.bin
* mrvl/txpwrlimit_cfg.bin
* mrvl/sd8777_uapsta.bin
* mrvl/WlanCalData_ext.conf
* mrvl/bt_cal_data.conf
* mrvl/txbackoff.txt
* mrvl/txpower_FC.bin
* mrvl/reg_alpha2
* ispfw_v325.bin

The command *wifi_on* and *wifi_off* control the Wi-Fi power state.

To use Wi-Fi in sation mode from the command line, uncomment the lines related to *wlan0* in */etc/network/interfaces* and set the *wpa-ssid* and *wpa-psk* for your network. Then to bring it up with:

```
$ ifup wlan0
```

From a graphic environment, *wlan0* will be picked by the *NetworkManager* (see below).

### Display with Xorg

The frame buffer device and console support is enabled in the kernel, which is how the login prompt is visible. It also offers good enough performances to run [Xorg](https://www.x.org) with the frame buffer driver as a fall back solution.

The command *display_on* and *display_off* control the display power state.

The issue with incorrect stride / pitch as well as pixel format can be solved by running *fbset*, see */usr/bin/fbset-fix-stride*:

```
$ fbset -xres 536 -yres 960 -rgba 8/16,8/8,8/0,8/24
```

## Use cases

### Xfce4 desktop

The [Xfce](https://xfce.org/) lightweight desktop environment and [LightDM](https://github.com/canonical/lightdm) are installed with:

```
$ apt install xfce4 lightdm
```

The LightDM login screen appears and the pointer can be controlled with the touchscreen:

![](doc/images/debian_buster_lightdm_portrait_login.png)

To auto-login and start directly to the desktop, set the following in */etc/lightdm/lightdm.conf*:

```
[SeatDefaults]
autologin-user=deb
...
```

![](doc/images/debian_buster_xfce4_desktop.png)

### Gnome desktop

The [Gnome](https://www.gnome.org/) desktop environment is installed with:

```
$ apt install gnome-core
```

The GDM login screen appears and the pointer can be controlled with the touchscreen:

![](doc/images/debian_buster_gdm_portrait_login.png)

To auto-login and start directly to the desktop, set the following in */etc/gdm3/daemon.conf*:

```
...
# Enabling automatic login
AutomaticLoginEnable = true
AutomaticLogin = deb
...
```

To trigger *fbset* when the session opens, create *.config/autostart/fbset.desktop* with:

```
[Desktop Entry]
Name=fbset-fix-stride
GenericName=fbset-fix-stride
Comment=
Exec=/usr/bin/fbset-fix-stride
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
```

![](doc/images/debian_buster_gnome_notifications.png)

![](doc/images/debian_buster_gnome_activities.png)

To trigger display an on-screen keyboard with *onboard* when the session opens, create *.config/autostart/onboard.desktop* with:

```
[Desktop Entry]
Name=onboard
GenericName=onboard
Comment=
Exec=onboard -s 540x200 -y 760 -x 0
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
```

In the *onboard* settings, select *Dock to screen edge*.

### Telegram

The following will install the [Telegram](https://telegram.org/) desktop client and *onboard* as on-screen keyboard to type messages with the touchscreen:

```
$ apt install onboard telegram-desktop
```

![](doc/images/debian_buster_telegram.png)

# Tips and tricks

## Display

### Frame buffer console rotation

Frame buffer console rotation is enabled at the kernel with *fbcon*. Value *0* means normal rotation, which is portrait mode on the phone, and value *1* means clockwise rotation, which is landscape mode on the phone. The value can be specified at boot time by adding to the kernel command line:

```
fbcon=rotate:1
```

At runtime, this value can be set like this:

```
echo 1 > /sys/class/graphics/fbcon/rotate
```

### Pitch and frame buffer color format

Per default, *Xorg* shows a stride effect and wrong colors due to incorrect frame buffer format. This can be fixed with *fbset*:

```
$ fbset -xres 536 -yres 960 -rgba 8/16,8/8,8/0,8/24
```

### Xorg (fbdev) orientation

Per default Xorg with fbdev will render in portrait mode on the phone. To switch to [landscape mode](https://www.x.org/archive/X11R6.8.1/doc/fbdev.4.html), create the file */etc/X11/xorg.conf* with:

```
Section "Device"  
  Identifier "fb"
  Driver "fbdev"
  Option "fbdev" "/dev/fb0"
  Option "Rotate" "CW"
EndSection
```

# More pages

* [Gallery](doc/Gallery.md)
* [Supported hardware](doc/Supported_hardware.md)
* [Recovery image and Buildroot](doc/Recovery_and_Buildroot.md)
* [Build a RAM-disk only system with Buildroot](doc/Recovery_image_Buildroot_RAM_disk.md)
* [Build TWRP](doc/Build_TWRP.md)
