#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later

import common
import os.path
import sys

if __name__ == "__main__":
    common.add_upstream_git_remote()
    apkbuilds = {file for file in common.get_changed_files(removed=False)
                 if os.path.basename(file) == "APKBUILD"}
    if len(apkbuilds) < 1:
        print("No APKBUILDs to lint")
        sys.exit(0)

    packages = []
    for apkbuild in apkbuilds:
        if apkbuild.startswith("temp/") or apkbuild.startswith("cross/"):
            print(f"NOTE: Skipping linting of {apkbuild}")
            continue
        packages.append(os.path.basename(os.path.dirname(apkbuild)))
    if len(packages) < 1:
        print("No APKBUILDs to lint")
        sys.exit(0)

    result = common.run_pmbootstrap(["-q", "lint"] + packages, output_return=True)

    if len(result) > 0:
        print("Linting issues found:")
        print(result)
        sys.exit(1)
