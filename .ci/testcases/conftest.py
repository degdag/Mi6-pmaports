#!/usr/bin/env python3
# Copyright 2021 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

import add_pmbootstrap_to_import_path
import pmb.parse
import pytest
import sys
import os


@pytest.fixture
def args(request):
    # Initialize args
    pmaports = os.path.realpath(f"{os.path.dirname(__file__)}/../..")
    sys.argv = ["pmbootstrap",
                "--aports", pmaports,
                "--log", "$WORK/log_testsuite_pmaports.txt"
                "chroot"]
    args = pmb.parse.arguments()

    # Initialize logging
    pmb.helpers.logging.init(args)
    request.addfinalizer(pmb.helpers.logging.logfd.close)
    return args
