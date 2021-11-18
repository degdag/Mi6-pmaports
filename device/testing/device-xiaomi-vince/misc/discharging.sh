#!/bin/sh

echo 0 > /sys/class/leds/red/brightness

# We'll vibrate a bit here.
echo 500 > /sys/class/leds/vibrator/duration                                                                                          
echo 100 > /sys/class/leds/vibrator/brightness
echo 1 > /sys/class/leds/vibrator/activate
