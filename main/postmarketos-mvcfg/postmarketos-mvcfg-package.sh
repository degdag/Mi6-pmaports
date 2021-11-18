#!/bin/sh -e

pkgdir="$1"
dirname="$2"

if [ -z "$dirname" ] || ! [ -d "$pkgdir" ]; then
	echo "usage:"
	# shellcheck disable=SC2016
	echo '  postmarketos-mvcfg-package "$pkgname" "$pkgdir"'
	echo "more information:"
	echo "  https://postmarketos.org/mvcfg"
	exit 1
fi

# Create "done" file, so postmarketos-mvcfg-pre-upgrade doesn't do anything
mkdir -p "$pkgdir/etc/postmarketos-mvcfg/done"
touch "$pkgdir/etc/postmarketos-mvcfg/done/$dirname"
