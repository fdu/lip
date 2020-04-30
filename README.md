# Linux in the pocket

This project brings bare-metal Linux desktop and services to smartphones.

Plenty of smartphones are sadly lying around, waiting for a second life. Most of them provide enough resources to be recycled as mini computers. With a variety of sensors, cameras, microphones, they are great battery-powered maker devices. As smartphones often support USB OTG, even more peripherals to be added for desktop use. This is only possible with software that allows customization. This repository shows how to build such a system using existing free and open-source software on [supported hardware](doc/Supported_hardware.md). See the [gallery](doc/Gallery.md) for applications.

![](doc/images/desktop_on_smartphone.png)

# Run Debian on your smartphone

## Recovery image with file system on SD card

Here the recovery image boots the device but the root file system is located on the SD card, which gives much more flexibility.

### Build

```
$ make recovery_sdcard
```

The recovery image to flash is created under *output/sdcard/recovery.img.tar*.

### Flash

On the smartphone used as reference, this file can be flashed with Odin (tested with 3.12.3). In AP, select the *output/sdcard/recovery.img.tar* file then click *Start*.

### Create Debian SD card

[Debootstrap](https://wiki.debian.org/Debootstrap) makes it super easy to populate a root file system for an architecture supported by [Debian](https://www.debian.org/):

```
$ make rootfs_sdcard
```

An archive of the root file system is created under *output/sdcard/rootfs.tar.gz*, ready to be extracted at the root of the SD card.

# More pages

* [Gallery](doc/Gallery.md)
* [Supported hardware](doc/Supported_hardware.md)
* [Recovery image and Buildroot](doc/Recovery_and_Buildroot.md)
* [Build a RAM-disk only system with Buildroot](doc/Recovery_image_Buildroot_RAM_disk.md)
* [Build TWRP](doc/Build_TWRP.md)
