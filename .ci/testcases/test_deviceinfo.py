#!/usr/bin/env python3
# Copyright 2021 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

import glob
import pytest
import sys
import os

import add_pmbootstrap_to_import_path
import pmb.parse


def deviceinfo_obsolete(info):
    """
    Test for obsolete options used in the deviceinfo file. They must still be
    defined in pmbootstrap's config/__init__.py.
    """
    obsolete_options = ["weston_pixman_type"]
    for option in obsolete_options:
        if info[option]:
            raise RuntimeError("option '" + option + "' is obsolete, please"
                               " remove it (reasons for removal are at"
                               " <https://postmarketos.org/deviceinfo>)")


def test_deviceinfo(args):
    """
    Parse all deviceinfo files successfully and run checks on the parsed data.
    """
    # Iterate over all devices
    last_exception = None
    count = 0
    for folder in glob.glob(args.aports + "/device/*/device-*"):
        device = folder[len(args.aports):].split("-", 1)[1]

        f = open(folder[len(args.aports):][1:] + "/deviceinfo")
        lines = f.read().split("\n")
        f.close()

        try:
            # variable can not be empty
            for line in lines:
                if '=""' in line:
                    raise RuntimeError("Please remove the empty variable: " + line)

            # Successful deviceinfo parsing / obsolete options
            info = pmb.parse.deviceinfo(args, device)
            deviceinfo_obsolete(info)

            # deviceinfo_name must start with manufacturer
            name = info["name"]
            manufacturer = info["manufacturer"]
            if not name.startswith(manufacturer) and \
                    not name.startswith("Google"):
                raise RuntimeError("Please add the manufacturer in front of"
                                   " the deviceinfo_name, e.g.: '" +
                                   manufacturer + " " + name + "'")

        # Don't abort on first error
        except Exception as e:
            last_exception = e
            count += 1
            print(device + ": " + str(e))

    # Raise the last exception
    if last_exception:
        print("deviceinfo error count: " + str(count))
        raise last_exception
