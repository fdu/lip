#!/bin/sh

wifi_on
sleep 5
ifconfig wlan0 up
wpa_supplicant -B w -D wext -i wlan0 -c /etc/wpa_supplicant.conf &