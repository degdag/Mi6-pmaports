#!/bin/sh

FILE=~/.screenoff
if [ -f $FILE ]; then
    xinput set-prop 8 "Device Enabled" 1
    xset dpms force on
    rm "$FILE"
else
    xinput set-prop 8 "Device Enabled" 0
    # Turn screen off twice (sometimes it does not work on first run)
    xset dpms force off
    xset dpms force off
    touch "$FILE"
fi
