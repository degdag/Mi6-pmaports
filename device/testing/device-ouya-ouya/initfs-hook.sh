#!/bin/sh

# downstream kernel
# fix display for xorg
if [ -d /sys/devices/tegradc.0 ]; then
	echo 0 > /sys/class/graphics/fb0/blank
	echo 16 > /sys/devices/tegradc.0/graphics/fb0/bits_per_pixel
	echo 0 0 > /sys/class/graphics/fb0/pan
fi


# mainline kernel
# set cooling governor that is meant for simple on/off cooling fans
if [ -d /sys/class/thermal/thermal_zone0 ]; then
	echo "bang_bang" | tee /sys/class/thermal/thermal_zone0/policy
fi
