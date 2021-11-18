#!/usr/bin/env python3
# Copyright 2021 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

import glob
import pytest
import sys
import os

import add_pmbootstrap_to_import_path
import pmb.parse
import pmb.parse._apkbuild


def device_dependency_check(apkbuild, path):
    """ Raise an error if a device package has a dependency that is not allowed
        (e.g. because it should be in a subpackage instead). """

    # asus-me176c: without this, the device will simply run the broken ACPI
    #              DSDT table, so we might as well update it. See pmaports!699.
    firmware_ok = {"device-asus-me176c": ["firmware-asus-me176c-acpi"]}

    pkgname = apkbuild["pkgname"]
    for depend in apkbuild["depends"]:
        if (depend.startswith("firmware-") or
                depend.startswith("linux-firmware")):
            if pkgname in firmware_ok and depend in firmware_ok[pkgname]:
                continue
            raise RuntimeError("Firmware package '" + depend + "' found in"
                               " depends of " + path + ". These go into"
                               " subpackages now, see"
                               " <https://postmarketos.org/devicepkg>.")


def test_aports_device(args):
    """
    Various tests performed on the /device/*/device-* aports.
    """
    for path in glob.iglob(args.aports + "/device/*/device-*/APKBUILD"):
        apkbuild = pmb.parse.apkbuild(args, path)

        # Depends: Require "postmarketos-base"
        if "postmarketos-base" not in apkbuild["depends"]:
            raise RuntimeError("Missing 'postmarketos-base' in depends of " +
                               path)

        # Depends: Must not have firmware packages
        for depend in apkbuild["depends"]:
            device_dependency_check(apkbuild, path)

        # Architecture
        device = apkbuild["pkgname"][len("device-"):]
        deviceinfo = pmb.parse.deviceinfo(args, device)
        if "".join(apkbuild["arch"]) != deviceinfo["arch"]:
            raise RuntimeError("wrong architecture, please change to arch=\"" +
                               deviceinfo["arch"] + "\": " + path)
        if "!archcheck" not in apkbuild["options"]:
            raise RuntimeError("!archcheck missing in options= line: " + path)

        if deviceinfo["flash_kernel_on_update"] == "true" \
                and "postmarketos-update-kernel" not in apkbuild["depends"]:
            raise RuntimeError(
                "Deviceinfo indicates this device supports automatic kernel"
                " flashing on update, but doesn't depend on"
                " 'postmarketos-update-kernel'. Please add the missing"
                " dependency.")


def test_aports_device_kernel(args):
    """
    Verify the kernels specified in the device packages:
    * Kernel must not be in depends when kernels are in subpackages
    * Check if only one kernel is defined in depends
    """

    # Iterate over device aports
    for path in glob.glob(args.aports + "/device/*/device-*/APKBUILD"):
        # Parse apkbuild and kernels from subpackages
        apkbuild = pmb.parse.apkbuild(args, path)
        device = apkbuild["pkgname"][len("device-"):]
        kernels_subpackages = pmb.parse._apkbuild.kernels(args, device)

        # Parse kernels from depends
        kernels_depends = []
        for depend in apkbuild["depends"]:
            if not depend.startswith("linux-"):
                continue
            kernels_depends.append(depend)

            # Kernel in subpackages *and* depends
            if kernels_subpackages:
                raise RuntimeError("Kernel package '" + depend + "' needs to"
                                   " be removed when using kernel" +
                                   " subpackages: " + path)

        # No kernel
        if not kernels_depends and not kernels_subpackages:
            raise RuntimeError("Device doesn't have a kernel in depends or"
                               " subpackages: " + path)

        # Multiple kernels in depends
        if len(kernels_depends) > 1:
            raise RuntimeError("Please use kernel subpackages instead of"
                               " multiple kernels in depends (see"
                               " <https://postmarketos.org/devicepkg>): " +
                               path)


def test_aports_maintained(args):
    """
    Ensure that aports in /device/{main,community} have "Maintainer:" and
    "Co-Maintainer:" (only required for main) listed in their APKBUILDs.
    """
    for path in glob.iglob(f"{args.aports}/device/main/*/APKBUILD"):
        if '/firmware-' in path:
            continue
        maintainers = pmb.parse._apkbuild.maintainers(path)
        assert maintainers and len(maintainers) >= 2, \
            f"{path} in main needs at least 1 Maintainer and 1 Co-Maintainer"

    for path in glob.iglob(f"{args.aports}/device/community/*/APKBUILD"):
        if '/firmware-' in path:
            continue
        maintainers = pmb.parse._apkbuild.maintainers(path)
        assert maintainers, f"{path} in community needs at least 1 Maintainer"


def test_aports_unmaintained(args):
    """
    Ensure that aports in /device/unmaintained have an "Unmaintained:" comment
    that describes why the aport is unmaintained.
    """
    for path in glob.iglob(f"{args.aports}/device/unmaintained/*/APKBUILD"):
        unmaintained = pmb.parse._apkbuild.unmaintained(path)
        assert unmaintained, f"{path} should have an Unmaintained: " +\
            "comment that describes why the package is unmaintained"
