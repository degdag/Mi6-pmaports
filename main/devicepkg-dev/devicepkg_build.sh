#!/bin/sh
startdir=$1
pkgname=$2

if [ -z "$startdir" ] || [ -z "$pkgname" ]; then
	echo "ERROR: missing argument!"
	echo "Please call $0 with \$startdir \$pkgname as arguments."
	exit 1
fi

srcdir="$startdir/src"

if [ ! -f "$srcdir/deviceinfo" ]; then
	echo "NOTE: $0 is intended to be used inside of the build() function"
	echo "of a device package's APKBUILD only."
	echo "ERROR: deviceinfo file missing!"
	exit 1
fi

# shellcheck disable=SC1090,SC1091
. "$srcdir/deviceinfo"

# Create splash screens
generate_splash_screens()
{
	splash_config="/etc/postmarketos/splash.ini"
	splash_width=${deviceinfo_screen_width:-720}
	splash_height=${deviceinfo_screen_height:-1280}

	# Overwrite $@ to easily iterate over the splash screens. Format:
	# $1: splash_name
	# $2: text
	# $3: arguments
	set -- "splash-loading"          "Loading..." "--center" \
	       "splash-noboot"           "boot partition not found\\nhttps://postmarketos.org/troubleshooting" "--center" \
	       "splash-noinitramfsextra" "initramfs-extra not found\\nhttps://postmarketos.org/troubleshooting" "--center" \
	       "splash-norootfs"         "rootfs not found\\nhttps://postmarketos.org/troubleshooting" "--center" \
	       "splash-resizefs"         "Loading...\\nResizing file system during initial boot" "--center" \
	       "splash-mounterror"       "unable to mount root partition\\nhttps://postmarketos.org/troubleshooting" "--center" \
	       "splash-debug-shell"      "WARNING\\ndebug-shell is active\\nhttps://postmarketos.org/debug-shell" "--center" \
	       "splash-charging-error"   "CHARGING MODE\\nerror starting charging-sdl\\nhttps://postmarketos.org/troubleshooting" "--center"

	# Loop through the splash screens definitions
	while [ $# -gt 2 ]
	do
		splash_name=$1
		splash_text=$2
		splash_args=$3

		# shellcheck disable=SC2154
		if [ "${deviceinfo_framebuffer_landscape}" = "true" ]; then
			splash_args="${splash_args} --landscape"
		fi

		# shellcheck disable=SC2086
		pmos-make-splash --text="${splash_text}" $splash_args --config "${splash_config}" \
				"$splash_width" "$splash_height" "$srcdir/${splash_name}.ppm"
		gzip "$srcdir/${splash_name}.ppm"

		shift 3 # move to the next 3 arguments
	done
}

# Convert an input calibration matrix from pixel coordinates to 0-1 coordinates
# and echo it for libinput.
# Parameters:
# $1: x multiplier for x coordinate
# $2: y multiplier for x coordinate
# $3: pixel offset for x coordinate
# $4: x multiplier for y coordinate
# $5: y multiplier for y coordinate
# $6: pixel offset for y coordinate
echo_libinput_calibration()
{
	# Check if we have got the required number of parameters.
	if [ $# -ne 6 ]; then
		echo "WARNING: There must be exactly 6 (or 0) values for the touchscreen calibration." >&2
		echo "WARNING: No calibration matrix for x11/libinput will be generated." >&2
		return
	fi

	# Check if we have got a screen width and screen height.
	# shellcheck disable=SC2154
	if [ -z "$deviceinfo_screen_width" ] || [ -z "$deviceinfo_screen_height" ]; then
		echo "WARNING: Screen width and height are required to generate a calibration matrix for x11/libinput." >&2
		echo "WARNING: No calibration matrix for x11/libinput will be generated." >&2
		return
	fi

	# Perform the actual conversion: divide both offsets by width/height.
	# As the "dc" command from "bc" is incompatible to the one provided by busybox,
	# this calls busybox explicitly.
	# shellcheck disable=SC2154
	x_offset=$(busybox dc "$3" "$deviceinfo_screen_width" / p)
	# shellcheck disable=SC2154
	y_offset=$(busybox dc "$6" "$deviceinfo_screen_height" / p)
	# Check if we have got results from dc. If there was an error, dc should have
	# printed an error message that hopefully gives the user a hint why it failed.
	if [ -z "$x_offset" ] || [ -z "$y_offset" ]; then
		echo "WARNING: Calculating the offsets for the calibration matrix for x11/libinput failed." >&2
		echo "No calibration matrix for x11/libinput will be generated." >&2
		return
	fi

	echo "ENV{LIBINPUT_CALIBRATION_MATRIX}=\"$1 $2 $x_offset $4 $5 $y_offset\", \\"
}

# Generate the contents for /etc/machine-info
generate_machine_info()
{
	{
		# shellcheck disable=SC2154
		echo "PRETTY_HOSTNAME=\"$deviceinfo_name\""
		# shellcheck disable=SC2154
		echo "CHASSIS=\"${deviceinfo_chassis}\""
	} > "$srcdir/machine-info"
}

generate_splash_screens

generate_machine_info

# shellcheck disable=SC2154
if [ -n "$deviceinfo_dev_touchscreen" ]; then
	# Create touchscreen udev rule
	{
		echo "SUBSYSTEM==\"input\", ENV{DEVNAME}==\"$deviceinfo_dev_touchscreen\", \\"
		# shellcheck disable=SC2154
		if [ -n "$deviceinfo_dev_touchscreen_calibration" ]; then
			echo "ENV{WL_CALIBRATION}=\"$deviceinfo_dev_touchscreen_calibration\", \\"

			# The following intentionally expands the touchscreen calibration into the
			# 6 values that should be there.
			# shellcheck disable=SC2086
			echo_libinput_calibration $deviceinfo_dev_touchscreen_calibration
		fi
		echo "ENV{ID_INPUT}=\"1\", ENV{ID_INPUT_TOUCHSCREEN}=\"1\""
	} > "$srcdir/90-$pkgname.rules"
fi
