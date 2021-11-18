#!/bin/sh

# We'll vibrate a bit here, then turn the led on.
echo 500 > /sys/class/timed_output/vibrator/enable
echo 100 > /sys/class/leds/white/brightness
