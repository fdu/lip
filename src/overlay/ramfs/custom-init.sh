#!/bin/sh

mount -t devtmpfs devtmpfs /dev

/bootmenu.py
bootchoice=`cat /tmp/bootchoice`

if [ "$bootchoice" = "ramdisk" ]; then
  exec /sbin/init
elif [ "$bootchoice" = "shell" ]; then
  exec /bin/sh
else
  mount -t proc /proc
  mount $bootchoice /mnt
  exec switch_root /mnt /sbin/init
fi;

exec /bin/sh
