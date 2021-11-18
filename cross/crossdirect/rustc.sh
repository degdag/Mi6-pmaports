#!/bin/sh -e

rust_triplet() {
	# Find the triplets in Alpine's rust APKBUILD or with:
	# pmbootstrap chroot -barmhf --add=rust -- ls /usr/lib/rustlib
	case "$1" in
		x86_64)
			echo "x86_64-alpine-linux-musl"
			;;
		armhf)
			echo "armv6-alpine-linux-musleabihf"
			;;
		armv7)
			echo "armv7-alpine-linux-musleabihf"
			;;
		aarch64)
			echo "aarch64-alpine-linux-musl"
			;;
		*)
			echo "ERROR: don't know the rust triple for $1!" >&2
			exit 1
			;;
	esac
}

arch="@ARCH@" # filled in by APKBUILD

if ! LD_LIBRARY_PATH=/native/lib:/native/usr/lib \
	/native/usr/bin/rustc \
		-Clinker=/native/usr/lib/crossdirect/rust-qemu-linker \
		--target=$(rust_triplet "$arch") \
		--sysroot=/usr \
		"$@"; then
	echo "---" >&2
	echo "WARNING: crossdirect: cross compiling with rustc failed, trying"\
		"again with rustc + qemu" >&2
	echo "---" >&2
	# Usually the crossdirect approach works; however, when passing
	# --extern to rustc with a dynamic library (.so), it fails with an
	# error like 'can't find crate for `serde_derive`' (although the crate
	# does exist). I think it fails to parse the metadata of the so file
	# for some reason. We probably need to adjust rustc's
	# librustc_metadata/locator.rs or something (and upstream that
	# change!), but I've spent enough time on this already. Let's simply
	# fall back to compiling in qemu in the very few cases where this is
	# necessary.
	/usr/bin/rustc "$@"
fi
