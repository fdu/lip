# Recovery image with Buildroot RAM disk as root file system

This recovery image is sufficient to run a minimal system. The user space components come from a RAM disk bundled in the image. It is limited to a few megabytes in size.

## Build

```
$ make recovery_ramfs
```

The recovery image to flash is created under *output/ramfs/recovery.img.tar*.

## Flash

On the smartphone used as reference, this file can be flashed with Odin (tested with 3.12.3). In AP, select the *output/ramfs/recovery.img.tar* file then click *Start*.

## Boot menu

For demonstration, a boot menu appears when the system starts. It is a simple interactive [micropython](https://micropython.org/) script that can be controlled with the volume and the home keys. The following options are available by default:
* shell: continue standard Buildroot boot to login
* wlan0 STA and display off: turn off the display to save energy, connect Wi-Fi in station mode according to *src/overlay/ramfs/etc/wpa_supplicant.conf*
* wlan0 AP and display off: : turn off the display to save energy, start Wi-Fi in access point mode according to *src/overlay/ramfs/etc/hostapd/hostapd.conf*

## Connect via SSH over USB

The [Dropbear](https://matt.ucc.asn.au/dropbear/dropbear.html) SSH server is started, the USB ethernet interface on the target statically takes the IP *192.168.234.2*. By setting the host USB ethernet interface to IP *192.168.234.1*, a connection to the target can be established with:
```
$ ssh root@192.168.234.2
```
Default password is *root*.

## Customization

### Firmware

Some binary firmware files might be expected by the device specific kernel drivers. If so, they must be extracted from the original system or a backup image and copied to *src/overlay/ramfs/lib/firmware/*. With the smartphone used as reference, those files are:
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

### USB ethernet

The system is configured to bring up the *rndis0* network interface (USB ethernet) is connected to a USB host at boot time. The IP configuration can be changed in *src/overlay/ramfs/etc/network/interfaces*.

### Wi-Fi

The SSID and PSK can be added before building in *src/overlay/ramfs/etc/wpa_supplicant.conf*. Some scripts will bring up the interface if started with:

```
$ ifup wlan0
```

Alternatively, *src/overlay/ramfs/etc/network/interfaces* can be edited so that the interface is brought up at startup by uncommenting *auto wlan0*.
