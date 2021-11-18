#!/bin/sh

# fix touchscreen in osk-sdl
source /sys/devices/soc0/7000c400.i2c/i2c-1/1-005b/0018\:03EB\:8207.000?/input/input?/event?/uevent
ln -s /dev/$DEVNAME /dev/input/touchscreen
