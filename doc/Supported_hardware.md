# TWRP

## Build

To build TWRP for the smartphone used as reference, the following Docker container can be used:

```
FROM debian:9
RUN apt update
RUN apt install -y git make schedtool python3 imagemagick curl openjdk-8-jdk unzip nano python bc bison flex zip git make schedtool python3 imagemagick curl openjdk-8-jdk libc6-dev-i386 build-essential g++-multilib
RUN git config --global user.name "Your Name"
RUN git config --global user.email "you@example.com"
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo
RUN sed -i "s/\#\!\/usr\/bin\/env\spython/\#\!\/usr\/bin\/python3/" /usr/bin/repo
RUN sed -i "s/MIN_PYTHON_VERSION\s=\s(3,\s6)/MIN_PYTHON_VERSION = (3, 5)/" /usr/bin/repo
RUN chmod +x /usr/bin/repo
```

From within the container:

```
$ repo init -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-5.1
```

In *.repo/manifest.xml* add:

```
<project path="device/samsung/grandprimevelte" name="TeamWin/android_device_samsung_grandprimevelte" remote="github" revision="android-5.1" />
```

Then run:

```
$ repo sync
$ . build/envsetup.sh
```

Comment *device/common/gps/gps_us_supl.mk* in *device/samsung/grandprimevelte/device.mk*.

Comment *$(error stopping)* in *bootable/recovery/minuitwrp/Android.mk* after *TW_BOARD_CUSTOM_GRAPHICS support has been deprecated in TWRP*

Finally build with:

```
$ lunch omni_grandprimevelte-eng
$ mka recoveryimage ALLOW_MISSING_DEPENDENCIES=true
```

## Links

* https://github.com/diepquynh/android_kernel_samsung_grandprimeve3g
* https://github.com/Shubzz-02/Samsung_grandprimevelte_Kernel
* https://github.com/TeamWin/android_device_samsung_grandprimevelte
