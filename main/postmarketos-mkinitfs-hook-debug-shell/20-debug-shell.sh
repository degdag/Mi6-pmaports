#!/bin/sh
# shellcheck disable=SC1091
. /etc/deviceinfo
. ./init_functions.sh
TELNET_PORT=23

setup_usb_network
start_udhcpd

show_splash /splash-debug-shell.ppm.gz

echo "Create 'pmos_continue_boot' script"
{
	echo "#!/bin/sh"
	echo "pkill -f pmos_shell"
	echo "pkill -f pmos_loop_forever"
	echo "pkill -f telnetd.*:${TELNET_PORT}"
} >/usr/bin/pmos_continue_boot
chmod +x /usr/bin/pmos_continue_boot

echo "Create 'pmos_shell' script"
{
	echo "#!/bin/sh"
	echo "sh"
} >/usr/bin/pmos_shell
chmod +x /usr/bin/pmos_shell

echo "Create 'pmos_loop_forever' script"
{
	echo "#!/bin/sh"
	echo '. /init_functions.sh'
	echo "loop_forever"
} >/usr/bin/pmos_loop_forever
chmod +x /usr/bin/pmos_loop_forever

echo "Start the telnet daemon"
{
	echo "#!/bin/sh"
	echo "echo \"Type 'pmos_continue_boot' to continue booting:\""
	echo "sh"
} >/telnet_connect.sh
chmod +x /telnet_connect.sh
telnetd -b "${IP}:${TELNET_PORT}" -l /telnet_connect.sh

# mount pstore, if possible
if [ -d /sys/fs/pstore ]; then
	mount -t pstore pstore /sys/fs/pstore || true
fi

echo "---"
echo "WARNING: debug-shell is active on ${IP}:${TELNET_PORT}."
echo "This is a security hole! Only use it for debugging, and"
echo "uninstall the debug-shell hook afterwards!"
echo "---"

if tty -s; then
	echo "Exit the shell to continue booting:"
	pmos_shell
else
	echo "No tty attached, looping forever."
	pmos_loop_forever
fi
