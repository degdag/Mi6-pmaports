#!/bin/sh
# Move all configs that were created/modified with legacy methods in
# post-install scripts.

if [ "$#" -lt 2 ]; then
	echo "usage:"
	echo "  postmarketos-mvcfg-pre-upgrade dirname cfg [cfg ...]"
	echo "example:"
	echo "  postmarketos-mvcfg-pre-upgrade \\"
	echo "    postmarketos-base \\"
	echo "    /etc/issue \\"
	echo "    /etc/fstab"
	echo "more information:"
	echo "  https://postmarketos.org/mvcfg"
	exit 1
fi

# Skip if "done" file exists. This is created in package() with
# postmarketos-mvcfg-package, so this script doesn't do anything if the package
# installed at pre-upgrade time is already using properly packaged configs.
dirname="$1"
if [ -e "/etc/postmarketos-mvcfg/done/$dirname" ]; then
	exit 0
fi

# Only act on existing files
shift
cfgs_found=""
for i in "$@"; do
	if [ -e "$i" ]; then
		cfgs_found="$cfgs_found $i"
	fi
done

if [ -n "$cfgs_found" ]; then
	# Create non-existing backupdir
	backupdir="/etc/postmarketos-mvcfg/backup/$dirname"
	while [ -d "$backupdir" ]; do
		backupdir="${backupdir}_"
	done
	mkdir -p "$backupdir"

	# Copy all configs first
	for i in $cfgs_found; do
		# Generate non-existing target path
		# flatpath: /etc/issue -> etc-issue
		flatpath="$(echo "$i" | sed s./.-.g | cut -d- -f2-)"
		target="$backupdir/$flatpath"
		while [ -e "$target" ]; do
			target="${target}_"
		done

		cp -a "$i" "$target"
	done

	# Remove configs
	for i in $cfgs_found; do
		rm "$i"
	done

	# List moved configs
	echo "  *"
	echo "  * These configs were created with legacy packaging methods:"
	for i in $cfgs_found; do
		echo "  *   $i"
	done
	echo "  *"
	echo "  * In order to replace them with properly packaged configs,"
	echo "  * the old versions (which you might have adjusted manually)"
	echo "  * were moved to:"
	echo "  *   $backupdir"
	echo "  *"
	echo "  * If you did not manually adjust these configs, you can ignore"
	echo "  * this message."
	echo "  *"
	echo "  * More information: https://postmarketos.org/mvcfg"
	echo "  *"
fi

# Make sure that the "done" file exists, even if the packager forgot to call
# 'postmarketos-mvcfg-package' in package() of the APKBUILD.
mkdir -p "/etc/postmarketos-mvcfg/done"
touch "/etc/postmarketos-mvcfg/done/$dirname"
