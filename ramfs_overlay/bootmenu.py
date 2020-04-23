#!/usr/bin/micropython

import struct
import sys
import os

# Configuration
input_event_struct = "llHHI"
input_event_device = "/dev/input/event5"
text_selected = "\\e[1;33m"
text_normal = "\\e[0m"
menu_entries = ["shell", "wlan0 STA and display off", "wlan0 AP and display off"]
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
      print_selected("  -> " + menu_entries[i])
    else:
      print("  -> " + menu_entries[i])

def execute(action):
  if action == 0:
    print("Going to shell...")
  elif action == 1:
    os.system("display_off")
    os.system("ifup wlan0")
  elif action == 2:
    os.system("display_off")
    os.system("access_point_on")
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