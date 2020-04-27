# Linux in the pocket

This project brings bare-metal Linux desktop and services to smartphones.

Plenty of smartphones are sadly lying around, waiting for a second life. Most of them provide enough resources to be recycled as mini computers. With a variety of sensors, cameras, microphones, they are great battery-powered maker boards. As smartphones often support USB OTG, even more peripherals to be added for desktop use. 

This is only possible with software that allows customization. This repository shows how to build such a system using existing free and open-source software. Only because I had a spare one, I am using [this model](https://www.samsung.com/levant/smartphones/galaxy-grand-prime-g531h/) as reference. Similar work is possible with other smartphones and other embedded devices.

## Before starting

### Recovery image

Many unlocked smartphones can be flashed with alternative recovery systems such as [TWRP](https://twrp.me/). Thanks to such projects, some public repositories point to the exact software components that run on each supported device. Those components are assembled in a recovery image that is flashed to the recovery partition. It contains at least a compressed Linux kernel, a RAM disk and a device tree blob (DTB). Here we will build a generic Linux recovery image that can be used for various use cases and not only as a recovery system.

### Buildroot

[Buildroot](https://www.buildroot.org/) is a great tool for creating such a recovery image. With the correct configuration, it will build a toolchain and other tools for the host, a Linux kernel and a root file system for our target.

In this particular case, the kernel depends on a specialized class of compiler. This compiler is not suited to build the user space components of the root file system. For this task we will rely on the compiler built by Buildroot. This means there are 2 toolchains at play to build our system.

### Warning

Following these instructions is very fun and teaches a lot, but it is also likely to render a smartphone unusable. Use at your own risk!

## Quick start

The *Makefile* should execute all tasks that will lead to the creation of the recovery image, from downloading the sources to configuring the components to compiling and assembling the image.

### Option 1: RAM disk root file system

With this option, the recovery image is sufficient to run a minimal system. The user space components come from a RAM disk bundled in the image. It is limited to a few megabytes in size.

Build with:

```
$ make recovery_ramfs
```

The recovery image to flash is created under *output/ramfs/recovery.img.tar*.
