setenv bootargs init=/init.sh rw console=ttymxc0,115200 cma=256M PMOS_NO_OUTPUT_REDIRECT PMOS_FORCE_PARTITION_RESIZE
setenv mmcdev 0
setenv mmcpart 1

printenv

# select the correct dtb based on device revision
# default to "-r2" if board_rev isn't set, since it'll boot on any librem5
# revision
dtb_file=imx8mq-librem5-r2.dtb
if itest.s "x3" == "x$board_rev" ; then
        dtb_file=imx8mq-librem5-r3.dtb
elif itest.s "x4" == "x$board_rev" ; then
        dtb_file=imx8mq-librem5-r4.dtb
fi

echo Loading DTB
ext2load mmc ${mmcdev}:${mmcpart} ${fdt_addr_r} ${dtb_file}

echo Loading Initramfs
ext2load mmc ${mmcdev}:${mmcpart} ${ramdisk_addr_r} uInitrd

echo Loading Kernel
ext2load mmc ${mmcdev}:${mmcpart} ${kernel_addr_r} vmlinuz

echo Resizing FDT
fdt addr ${fdt_addr_r}
fdt resize

echo Booting kernel
booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}
