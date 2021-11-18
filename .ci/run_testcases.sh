#!/bin/sh -e
# Copyright 2021 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

# Require pmbootstrap
if ! command -v pmbootstrap > /dev/null; then
	echo "ERROR: pmbootstrap needs to be installed."
	exit 1
fi

# Wrap pmbootstrap to use this repository for --aports
pmaports="$(cd $(dirname $0)/..; pwd -P)"
_pmbootstrap="$(command -v pmbootstrap)"
pmbootstrap() {
	"$_pmbootstrap" --aports="$pmaports" "$@"
}

# Make sure that the work folder format is up to date, and that there are no
# mounts from aborted test cases (pmbootstrap#1595)
pmbootstrap work_migrate
pmbootstrap -q shutdown

# Make sure we have a valid device (pmbootstrap#1128)
device="$(pmbootstrap config device)"
deviceinfo="$pmaports/device/*/device-$device/deviceinfo"
if ! [ -e $deviceinfo ]; then
	echo "ERROR: Could not find deviceinfo file for selected device '$device'."
	echo "Expected path: $deviceinfo"
	echo "Maybe you have switched to a branch where your device does not exist?"
	echo "Use 'pmbootstrap config device qemu-amd64' to switch to a valid device."
	exit 1
fi

# Run testcases
pytest -vv -x --tb=native "$pmaports/.ci/testcases" "$@"
