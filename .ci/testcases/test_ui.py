#!/usr/bin/env python3
# Copyright 2021 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

import glob
import pytest
import sys
import os

import add_pmbootstrap_to_import_path
import pmb.parse


def test_aports_ui(args):
    """
    Raise an error if package in _pmb_recommends is not found
    """
    for arch in pmb.config.build_device_architectures:
        for path in glob.iglob(args.aports + "/main/postmarketos-ui-*/APKBUILD"):
            apkbuild = pmb.parse.apkbuild(args, path)
            # Skip if arch isn't enabled
            if not pmb.helpers.package.check_arch(args, apkbuild["pkgname"], arch, False):
                continue

            for package in apkbuild["_pmb_recommends"]:
                depend = pmb.helpers.package.get(args, package,
                                                 arch, must_exist=False)
                if depend is None or not pmb.helpers.package.check_arch(args, package, arch):
                    raise RuntimeError(f"{path}: package '{package}' from"
                                       f" _pmb_recommends not found for arch '{arch}'")

            # Check packages from "_pmb_recommends" of -extras subpackage if one exists
            if f"{apkbuild['pkgname']}-extras" in apkbuild["subpackages"]:
                apkbuild = apkbuild["subpackages"][f"{apkbuild['pkgname']}-extras"]
                for package in apkbuild["_pmb_recommends"]:
                    depend = pmb.helpers.package.get(args, package,
                                                     arch, must_exist=False)
                    if depend is None or not pmb.helpers.package.check_arch(args, package, arch):
                        raise RuntimeError(f"{path}: package '{package}' from _pmb_recommends "
                                           f"of -extras subpackage is not found for arch '{arch}'")
