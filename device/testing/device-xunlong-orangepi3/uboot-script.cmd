if test ${mmc_bootdev} -eq 0 ; then
	echo "Booting from SD";
	setenv bootdev 0;
else
	echo "Booting from eMMC";
	setenv bootdev 2;
fi;

setenv bootargs init=/init.sh rw console=tty0 console=ttyS0,115200 earlycon no_console_suspend panic=10 consoleblank=0 loglevel=1 pmos_boot=/dev/mmcblk${bootdev}p1 pmos_root=/dev/mmcblk${bootdev}p2 PMOS_NO_OUTPUT_REDIRECT

printenv

echo Loading DTB
load mmc ${mmc_bootdev}:1 ${fdt_addr_r} sun50i-h6-orangepi-3.dtb

echo Loading Initramfs
load mmc ${mmc_bootdev}:1 ${ramdisk_addr_r} uInitrd

echo Loading Kernel
load mmc ${mmc_bootdev}:1 ${kernel_addr_r} vmlinuz

echo Resizing FDT
fdt addr ${fdt_addr_r}
fdt resize

echo Booting kernel
booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
