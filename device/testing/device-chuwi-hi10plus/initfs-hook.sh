#!/bin/sh

# If the device is booted from kernelflinger bootloader,
# there is a watchdog running as soon the device load it's kernel.
#
# When watchdog is running, the system will reboot after 100 seconds,
#
# The script below will run "Magic Close", which will stop the timer. (thanks lambdadroid)
# http://lxr.free-electrons.com/source/Documentation/watchdog/watchdog-api.txt

# snip from device-nokia-n9 (initfs-hook.sh)
for wd in /dev/watchdog*; do
    [ -c $wd ] && echo V > $wd
done
