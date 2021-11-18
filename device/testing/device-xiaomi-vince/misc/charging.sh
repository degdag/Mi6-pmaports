#!/bin/sh

# We'll vibrate a bit here, then turn the led on.
echo 500 > /sys/class/leds/vibrator/duration                                                                                          
echo 100 > /sys/class/leds/vibrator/brightness
echo 1 > /sys/class/leds/vibrator/activate
echo 150 > /sys/class/leds/red/brightness
