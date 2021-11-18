#!/bin/sh -e

# Each argument to this shell script is a path that caused the trigger to execute. 
# If /etc/deviceinfo was installed (which should be the case for any device) and 
# deviceinfo_getty is set, then configure a getty. 

deviceinfo="false"

for i in "$@"; do
	case "$i" in
		/etc)
			if [ -f /etc/deviceinfo ]; then 
				deviceinfo="true"
			fi
			break ;;
	esac
done

if [ "$deviceinfo" = "true" ]; then
	deviceinfo_getty=""

	# shellcheck disable=SC1091
	. /etc/deviceinfo

	if [ -n "${deviceinfo_getty}" ]; then
		port=$(echo "${deviceinfo_getty}" | cut -s -d ";" -f 1)
		baudrate=$(echo "${deviceinfo_getty}" | cut -s -d ";" -f 2)

		if [ -n "${port}" ] && [ -n "${baudrate}" ]; then
			echo "Configuring a getty on port ${port} with baud rate ${baudrate}"
			sed -i -e "s/#ttyS0::respawn:\/sbin\/getty -L ttyS0 115200 vt100/${port}::respawn:\/sbin\/getty -L ${port} ${baudrate} vt100/" /etc/inittab
		else
			echo "ERROR: Invalid value for deviceinfo_getty: ${deviceinfo_getty}"
			exit 1
		fi
	fi
fi

sync
exit 0
