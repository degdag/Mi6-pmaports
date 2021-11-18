#!/usr/bin/env python3
# Copyright 2021 Johannes Marbach
# SPDX-License-Identifier: GPL-3.0-or-later

import glob
import os

import add_pmbootstrap_to_import_path
import pmb.parse


def test_aports_firmware(args):
    """
    Various tests performed on the /**/firmware-* aports.
    """

    excluded = [
        "firmware-motorola-potter",  # Depends on soc-qcom-msm8916-ucm
        "firmware-oneplus-sdm845",  # Depends on soc-qcom-sdm845-nonfree-firmware
        "firmware-samsung-baffinlite",  # Depends on firmware-aosp-broadcom-wlan
        "firmware-samsung-crespo",  # Depends on firmware-aosp-broadcom-wlan
        "firmware-samsung-maguro",  # Depends on firmware-aosp-broadcom-wlan
        "firmware-xiaomi-beryllium",  # Depends on soc-qcom-sdm845-nonfree-firmware
        "firmware-xiaomi-ferrari",  # Depends on soc-qcom-msm8916
        "firmware-xiaomi-willow",  # Doesn't build, source link is dead (pma#1212)
    ]

    for path in glob.iglob(f"{args.aports}/**/firmware-*/APKBUILD", recursive=True):
        apkbuild = pmb.parse.apkbuild(args, path)
        aport_name = os.path.basename(os.path.dirname(path))

        if aport_name not in excluded:
            if "pmb:cross-native" not in apkbuild["options"]:
                raise RuntimeError(f"{aport_name}: \"pmb:cross-native\" missing in"
                                   " options= line. The pmb:cross-native option is"
                                   " preferred because it results in significantly"
                                   " lower build times. If the package doesn't build"
                                   " with the option, you can add an exemption in"
                                   " .gitlab-ci/testcases/test_firmware.py.")

        if "!tracedeps" not in apkbuild["options"]:
            raise RuntimeError(f"{aport_name}: \"!tracedeps\" missing in"
                               " options= line. The tracedeps option is superfluous"
                               " for firmware packages.")
