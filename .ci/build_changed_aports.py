#!/usr/bin/env python3
# Copyright 2021 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later
import sys

# Same dir
import common

# pmbootstrap
import testcases.add_pmbootstrap_to_import_path
import pmb.parse
import pmb.parse._apkbuild
import pmb.helpers.pmaports


def build_strict(packages, arch):
    common.run_pmbootstrap(["build_init"])
    common.run_pmbootstrap(["--details-to-stdout", "--no-ccache", "build",
                            "--strict", "--force",
                            "--arch", arch, ] + list(packages))


def verify_checksums(packages, arch):
    # Only do this with one build-{arch} job
    arch_verify = "x86_64"
    if arch != arch_verify:
        print(f"NOTE: doing checksum verification in build-{arch_verify} job,"
              " not here.")
        return

    if len(packages) == 0:
        print("no packages changed, not doing any checksums verification")
        return

    common.run_pmbootstrap(["build_init"])
    common.run_pmbootstrap(["--details-to-stdout", "checksum", "--verify"] +
                           list(packages))


if __name__ == "__main__":
    # Architecture to build for (as in build-{arch})
    if len(sys.argv) != 2:
        print("usage: build_changed_aports.py ARCH")
        sys.exit(1)
    arch = sys.argv[1]

    # Get and print modified packages
    common.add_upstream_git_remote()
    packages = common.get_changed_packages()

    # Package count sanity check
    common.get_changed_packages_sanity_check(len(packages))

    # [ci:skip-build]: verify checksums and stop
    verify_only = common.commit_message_has_string("[ci:skip-build]")
    if verify_only:
        print("WARNING: not building changed packages ([ci:skip-build])!")
        print("verifying checksums: " + ", ".join(packages))
        verify_checksums(packages, arch)
        sys.exit(0)

    # Prepare "args" to use pmbootstrap code
    sys.argv = ["pmbootstrap", "chroot"]
    args = pmb.parse.arguments()

    # Filter out packages that can't be built for given arch
    # (Iterate over copy of packages, because we modify it in this loop)
    for package in packages.copy():
        apkbuild_path = pmb.helpers.pmaports.find(args, package)
        apkbuild = pmb.parse._apkbuild.apkbuild(args,
                                                f"{apkbuild_path}/APKBUILD")

        if not pmb.helpers.pmaports.check_arches(apkbuild["arch"], arch):
            print(f"{package}: not enabled for {arch}, skipping")
            packages.remove(package)

    # No packages: skip build
    if len(packages) == 0:
        print(f"no packages changed, which can be built for {arch}")
        sys.exit(0)

    # Build packages
    print(f"building in strict mode for {arch}: {', '.join(packages)}")
    build_strict(packages, arch)
