#!/bin/sh
# shellcheck disable=SC1091

[ -e /etc/postmarketos-mkinitfs/hooks/10-verbose-initfs.sh ] && set -x

. /etc/deviceinfo
. ./init_functions.sh

export PATH=/usr/bin:/bin:/usr/sbin:/sbin
/bin/busybox --install -s
/bin/busybox-extras --install -s

# Mount everything, set up logging, modules, mdev
mount_proc_sys_dev
create_device_nodes
setup_log
setup_firmware_path
# shellcheck disable=SC2154,SC2086
[ -d /lib/modules ] && modprobe -a ${deviceinfo_modules_initfs} ext4 usb_f_rndis

setup_mdev
mount_subpartitions
setup_framebuffer

# Hooks
for hook in /etc/postmarketos-mkinitfs/hooks/*.sh; do
	[ -e "$hook" ] || continue
	sh "$hook"
done

# Always run dhcp daemon/usb networking for now (later this should only
# be enabled, when having the debug-shell hook installed for debugging,
# or get activated after the initramfs is done with an OpenRC service).
setup_usb_network
start_udhcpd

mount_boot_partition /boot
show_splash_loading
extract_initramfs_extra /boot/initramfs-extra
# charging-sdl does not work properly at the moment, so skip it.
# See also https://gitlab.com/postmarketOS/pmaports/-/issues/1064
# start_charging_mode
wait_root_partition
delete_old_install_partition
resize_root_partition
unlock_root_partition
resize_root_filesystem
mount_root_partition

# Mount boot partition into sysroot, so OpenRC doesn't need to do it (#664)
umount /boot
mount_boot_partition /sysroot/boot "rw"

init="/sbin/init"
setup_bootchart2

# Switch root
killall telnetd mdev msm-fb-refresher 2>/dev/null
umount /proc
umount /sys
umount /dev/pts
umount /dev

# shellcheck disable=SC2093
exec switch_root /sysroot "$init"

echo "ERROR: switch_root failed!"
echo "Looping forever. Install and use the debug-shell hook to debug this."
echo "For more information, see <https://postmarketos.org/debug-shell>"
loop_forever
