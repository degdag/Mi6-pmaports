gpio set 98
gpio set 114

if test ${mmc_bootdev} -eq 0 ; then
	echo "Booting from SD";
	setenv bootdev 0;
else
	echo "Booting from eMMC";
	setenv bootdev 2;
fi;

setenv bootargs init=/init.sh rw console=tty0 console=ttyS0,115200 earlycon=uart,mmio32,0x01c28000 panic=10 consoleblank=0 loglevel=1 PMOS_NO_OUTPUT_REDIRECT PMOS_FORCE_PARTITION_RESIZE pmos_boot=/dev/mmcblk${bootdev}p1 pmos_root=/dev/mmcblk${bootdev}p2

printenv

echo Loading DTB
load mmc ${mmc_bootdev}:1 ${fdt_addr_r} ${fdtfile}

echo Loading Initramfs
load mmc ${mmc_bootdev}:1 ${ramdisk_addr_r} initramfs
setenv ramdisk_size ${filesize}

echo Loading Kernel
load mmc ${mmc_bootdev}:1 ${kernel_addr_r} vmlinuz

gpio set 115

echo Resizing FDT
fdt addr ${fdt_addr_r}
fdt resize

echo Adding FTD RAM clock
fdt mknode / memory
fdt set /memory ram_freq ${ram_freq}
fdt list /memory

echo Booting kernel
gpio set 116
gpio clear 98
booti ${kernel_addr_r} ${ramdisk_addr_r}:${ramdisk_size} ${fdt_addr_r}
