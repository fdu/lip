#!/usr/bin/micropython

import struct
import sys
import os

# Configuration
input_event_struct = "llHHI"
input_event_device = "/dev/input/event5"
text_selected = "\\e[1;33m"
text_normal = "\\e[0m"
menu_entries = [
  ["Shell", "shell"],
  ["RAM disk (Busybox init)", "ramdisk"],
  ["External SD card (/dev/mmcblk1p1)", "/dev/mmcblk1p1"],
  ["Interal eMMC (/dev/mmcblk0p16 SYSTEM)", "/dev/mmcblk0p16"],
  ["Interal eMMC (/dev/mmcblk0p19 USER)", "/dev/mmcblk0p19"],
]
menu_index = 0
button_code_home = 172
button_code_up = 115
button_code_down = 114
color_selected = '\033[42m'
color_normal = '\033[0m'
color_bootmenu = '\033[44m'

input_event_device = open(input_event_device, "rb")

def read_input():
  event = input_event_device.read(struct.calcsize(input_event_struct))
  (tv_sec, tv_usec, type, code, value) = struct.unpack(input_event_struct, event)
  if value == 1:
    return code

def print_selected(text):
  print(color_selected + text + color_normal)

def display():
  os.system("reset")
  print(color_bootmenu + " Boot menu " + color_normal)
  print()
  for i in range(len(menu_entries)):
    if i == menu_index:
      print_selected("  -> " + menu_entries[i][0])
    else:
      print("  -> " + menu_entries[i][0])

def execute(action):
  file = open("/tmp/bootchoice", "w")
  file.write(menu_entries[action][1])
  file.close()
  os.system("reset")
  sys.exit(0)

display()
while 1:
  code = read_input()
  if code == button_code_down and menu_index < (len(menu_entries) - 1):
    menu_index = menu_index + 1
    display()
  elif code == button_code_up and menu_index > 0:
    menu_index = menu_index - 1
    display()
  elif code == button_code_home:
    execute(menu_index)
