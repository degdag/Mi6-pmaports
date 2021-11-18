#!/bin/sh
# shellcheck disable=SC1091
. /etc/deviceinfo
. ./init_functions.sh

# mount pstore, if possible
if [ -d /sys/fs/pstore ]; then
	mount -t pstore pstore /sys/fs/pstore || true
fi

if tty -s; then
	tty=/dev/tty0
	modprobe uinput
	fbkeyboard -r $(cat /sys/class/graphics/fbcon/rotate) 2>$tty &
	echo "Exit the shell to continue booting:" > $tty
	sh +m <$tty >$tty 2>$tty
	pkill -f fbkeyboard
else
	echo "No tty attached, exiting."
fi
