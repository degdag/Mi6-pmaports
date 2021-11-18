#!/bin/sh
startdir=$1
pkgname=$2

if [ -z "$startdir" ] || [ -z "$pkgname" ]; then
	echo "ERROR: missing argument!"
	echo "Please call $0 with \$startdir \$pkgname as arguments."
	exit 1
fi

srcdir="$startdir/src"
pkgdir="$startdir/pkg/$pkgname"

if [ ! -f "$srcdir/deviceinfo" ]; then
	echo "NOTE: $0 is intended to be used inside of the package() function"
	echo "of a device package's APKBUILD only."
	echo "ERROR: deviceinfo file missing!"
	exit 1
fi

install -Dm644 "$srcdir/deviceinfo" \
	"$pkgdir/etc/deviceinfo"
install -Dm644 -t "$pkgdir/usr/share/postmarketos-splashes" "$srcdir"/*.ppm.gz
install -Dm644 "$srcdir/machine-info" \
	"$pkgdir/etc/machine-info"

if [ -f "$srcdir/90-$pkgname.rules" ]; then
	install -Dm644 "$srcdir/90-$pkgname.rules" \
		"$pkgdir/etc/udev/rules.d/90-$pkgname.rules"
fi

if [ -f "$srcdir/initfs-hook.sh" ]; then
	install -Dm644 "$srcdir/initfs-hook.sh" \
		"$pkgdir/etc/postmarketos-mkinitfs/hooks/00-$pkgname.sh"
fi

if [ -f "$srcdir/modules-load.conf" ]; then
	install -Dm644 "$srcdir/modules-load.conf" \
		"$pkgdir/etc/modules-load.d/00-$pkgname.conf"
fi

if [ -f "$srcdir/modprobe.conf" ]; then
	install -Dm644 "$srcdir/modprobe.conf" \
		"$pkgdir/etc/modprobe.d/$pkgname.conf"
fi
