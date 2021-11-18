#!/bin/sh
startdir=$1
pkgname=$2
subpkgname=$3

if [ -z "$startdir" ] || [ -z "$pkgname" ] || [ -z "$subpkgname" ]; then
	echo "ERROR: missing argument!"
	echo "Please call $0 with \$startdir \$pkgname \$subpkgname as arguments."
	exit 1
fi

srcdir="$startdir/src"
pkgdir="$startdir/pkg/$pkgname"
subpkgdir="$startdir/pkg/$subpkgname"

if [ -e "$pkgdir/etc/deviceinfo" ]; then
	rm -v "$pkgdir/etc/deviceinfo"
fi

install -Dm644 "$srcdir/deviceinfo" \
	"$subpkgdir/etc/deviceinfo"

# Get the kernel type ("downstream", "mainline")
kernel=$(echo "$subpkgname" | sed -n "s/.*-kernel-\(.*\)/\1/p" | tr - _)

# Iterate over deviceinfo variables that have the kernel type as suffix
# var looks like: deviceinfo_kernel_cmdline, ...
grep -E "(.+)_$kernel=.*" "$subpkgdir/etc/deviceinfo" | \
	sed "s/\(.\+\)_$kernel=.*/\1/g" | while IFS= read -r var
do
	if grep -Eq "$var=.*" "$subpkgdir/etc/deviceinfo"; then
		echo "ERROR: variable '$var' should contain a kernel subpackage suffix"
		exit 1
	fi

	# Remove the kernel suffix from the variable
	sed -i "s/$var\_$kernel/$var/g" "$subpkgdir/etc/deviceinfo"

	# Remove the variables with other kernel suffixes
	sed -i "/$var\_.*=.*/d" "$subpkgdir/etc/deviceinfo"
done
