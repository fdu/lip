# Recovery image

Many unlocked smartphones can be flashed with alternative recovery systems such as [TWRP](https://twrp.me/). Thanks to such projects, some public repositories point to the exact software components that run on each supported device. Those components are assembled in a recovery image that is flashed to the recovery partition. It contains at least a compressed Linux kernel, a RAM disk and a device tree blob (DTB). Here we will build a generic Linux recovery image that can be used for various use cases and not only as a recovery system.

# Buildroot

[Buildroot](https://www.buildroot.org/) is a great tool for creating such a recovery image. With the correct configuration, it will build a toolchain and other tools for the host, a Linux kernel and a root file system for our target.

In this particular case, the kernel depends on a specialized class of compiler. This compiler is not suited to build the user space components of the root file system. For this task we will rely on the compiler built by Buildroot. This means there are 2 toolchains at play to build our system.

The *Makefile* should execute all tasks that will lead to the creation of the recovery image, from downloading the sources to configuring the components to compiling and assembling the image.
