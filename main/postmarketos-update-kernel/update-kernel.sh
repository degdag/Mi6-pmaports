#!/bin/ash
# shellcheck shell=dash
set -e

# Declare used deviceinfo variables to pass shellcheck
deviceinfo_append_dtb=""

# shellcheck disable=SC1091
. /etc/deviceinfo

# On A/B devices with bootloader cmdline ON this will return the slot suffix
# if booting with an alternate method which erases the stock bootloader cmdline
# this will be empty and the update will fail.
# https://source.android.com/devices/bootloader/updating#slots
# On non-A/B devices this will be empty
ab_get_slot() {
	ab_slot_suffix=$(grep -o 'androidboot\.slot_suffix=..' /proc/cmdline |  cut -d "=" -f2) || :
	echo "$ab_slot_suffix"
}

update_android_fastboot() {
	BOOT_PART_SUFFIX=$(ab_get_slot) # Empty for non-A/B devices
	BOOT_PARTITION=$(findfs PARTLABEL="boot${BOOT_PART_SUFFIX}")
	echo "Flashing boot.img to 'boot${BOOT_PART_SUFFIX}'"
	dd if=/boot/boot.img of="$BOOT_PARTITION" bs=1M
}

update_android_split_kernel_initfs() {
	KERNEL_PARTITION=$(findfs PARTLABEL="${deviceinfo_flash_heimdall_partition_kernel:?}")
	INITFS_PARTITION=$(findfs PARTLABEL="${deviceinfo_flash_heimdall_partition_initfs:?}")

	KERNEL="vmlinuz"
	if [ "${deviceinfo_append_dtb}" = "true" ]; then
		KERNEL="$KERNEL-dtb"
	fi

	echo "Flashing kernel ($KERNEL)..."
	dd if=/boot/"$KERNEL" of="$KERNEL_PARTITION" bs=1M

	echo "Flashing initramfs..."
	gunzip -c /boot/initramfs | lzop | dd of="$INITFS_PARTITION" bs=1M
}

METHOD=${deviceinfo_flash_method:?}
case $METHOD in
	fastboot|heimdall-bootimg)
		update_android_fastboot
		;;
	heimdall-isorec)
		update_android_split_kernel_initfs
		;;
	0xffff)
		echo -n "No need to use this utility, since uboot loads the kernel directly from"
		echo " the boot partition. Your kernel should be updated already."
		exit 1
		;;
	*)
		echo "Devices with flash method: $METHOD are not supported."
		exit 1
		;;
esac
echo "Done."
