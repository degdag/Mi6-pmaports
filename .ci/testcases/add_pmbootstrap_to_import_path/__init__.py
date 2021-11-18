#!/usr/bin/env python3
# Copyright 2021 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

import shutil
import sys
import os
import importlib
import importlib.util
from distutils.sysconfig import get_python_lib


def path_pmbootstrap():
    """ Find the pmbootstrap installation folder, so we can import the Python
        code from there.
        returns: pmbootstrap installation folder
    """
    # Find 'pmbootstrap' executable
    bin = shutil.which("pmbootstrap")
    if not bin:
        print("ERROR: 'pmbootstrap' not found in $PATH")
        sys.exit(1)

    # Resolve the symlink and verify the folder
    dir = os.path.dirname(os.path.realpath(bin))
    if os.path.exists(dir + "/pmb/__init__.py"):
        return dir

    dir = get_python_lib()
    if os.path.exists(dir + "/pmb/__init__.py"):
        return dir

    # Symlink not set up properly
    print("ERROR: 'pmbootstrap' is not a symlink to pmbootstrap.py")
    sys.exit(1)


# Check if pmb module can be imported
if importlib.util.find_spec("pmb") is None:
    # Add pmbootstrap dir to import path
    sys.path.append(os.path.realpath(path_pmbootstrap()))
