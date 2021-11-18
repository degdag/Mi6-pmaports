#!/bin/sh

# Toggle between tty1 and tty2, launching fbkeyboard when on tty2
# THIS SCRIPT MUST BE RUN AS ROOT
# usage:
# togglevt.sh <state>
# where <state> is an optional arg to require that a counter be incremented before the action
# is performed. The default configuration will perform the switch when the power button has
# been pressed 3 times whilst the volume down button is being held.
# if no arguments are specified the switch will occur immediately.

[ "$(whoami)" != root ] && echo "This must be run as root" && exit 1

# shellcheck disable=SC1091
test -f /etc/conf.d/ttyescape.conf && . /etc/conf.d/ttyescape.conf

# default font, override this by setting it in /etc/conf.d/ttyescape.conf
FONT="${FONT:-/usr/share/consolefonts/ter-128n.psf.gz}"
# amount of times power must be pressed to trigger
PRESSCOUNT="${PRESSCOUNT:-3}"
TMPFILE="${TMPFILE:-/tmp/ttyescape.tmp}"

if [ ! -e /dev/uinput ]; then
	if ! modprobe -q uinput; then
		echo "uinput module not available, please enable it in your kernel"
	fi
fi

switchtty() {
	currentvt=$(cat /sys/devices/virtual/tty/tty0/active)

	if [ "$currentvt" = "tty2" ]; then # switch to tty1 with normal UI
		chvt 1
		killall fbkeyboard
	else # Switch to tty2 with fbkeyboard
		setfont "$FONT" -C /dev/tty2
		chvt 2
		# sometimes fbkeyboard can be running already, we shouldn't start it in that case
		[ "$(pgrep fbkeyboard)" ] || nohup fbkeyboard -r "$(cat /sys/class/graphics/fbcon/rotate)" &
	fi
}

# If we receive a command that isn't start
# and we don't have the file used to count
# then we should do nothing
if [ -n "$1" ] && [ "$1" != "start" ] && [ ! -f "$TMPFILE" ]; then
	exit 0
fi

case "$1" in
	# No args means just DO IT
	"")
		switchtty
		;;
	# Start counting, this should
	# run when voldown is pressed
	"start")
		echo "0" > "$TMPFILE"
		;;
	# Run when voldown releases
	"reset")
		rm "$TMPFILE"
		;;
	# Run when power pressed while
	# voldown is pressed
	"inc")
		val="$(cat "$TMPFILE")"
		val=$((val+1))
		if [ $val -eq "$PRESSCOUNT" ]; then
			rm "$TMPFILE"
			switchtty
		else
			echo "$val" > "$TMPFILE"
		fi
		;;
	*)
esac
