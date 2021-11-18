#!/usr/bin/env python3
# Copyright 2021 Oliver Smith
# SPDX-License-Identifier: GPL-3.0-or-later

import argparse
import glob
import os
import sys
import urllib.request


def get_devices():
    """:returns: list of all devices"""
    ret = []
    pmaports = (os.path.realpath(os.path.join(os.path.dirname(__file__) +
                "/..")))
    for path in glob.glob(pmaports + "/device/*/device-*/"):
        device = os.path.dirname(path).split("device-", 1)[1]

        # -downstream suffix is used when packaging the downstream kernel for
        # devices that have a working mainline kernel. Those are usually
        # unmaintained and therefore might not appear in the wiki. However,
        # the main device should be documented (remove the -downstream suffix).
        if device.endswith('-downstream'):
            device = device[:-len('-downstream')]

        ret.append(device)
    return sorted(ret)


def get_wiki_devices_html(path):
    """:param path: to a local file with the saved content of the devices wiki
                    page or None to download a fresh copy
       :returns: HTML of the page, split into booting and not booting:
                 {"booting": "<!DOCTYPE HTML>\n<html..."
                  "not_booting": "Not booting</span></h2>\n<p>These..."}"""
    content = ""
    if path:
        # Read file
        with open(path, encoding="utf-8") as handle:
            content = handle.read()
    else:
        # Download wiki page
        url = "http://wiki.postmarketos.org/wiki/Devices"
        content = urllib.request.urlopen(url).read().decode("utf-8")

    # Split into booting and not booting
    split = content.split("<span class=\"mw-headline\" id=\"Non-booting_devices\">")

    if len(split) != 2:
        print("*** Failed to parse wiki page")
        sys.exit(2)
    return {"booting": split[0], "not_booting": split[1]}


def get_wiki_renamed_devices_html():
    """:returns: HTML of the page"""
    # Download wiki page
    url = "http://wiki.postmarketos.org/wiki/Renamed_Devices"
    return urllib.request.urlopen(url).read().decode("utf-8")


def check_device(device, html, is_booting):
    """:param is_booting: require the device to be in the booting section, not
                          just anywhere in the page (i.e. in the not booting
                          table).
       :returns: True when the device is in the appropriate section."""
    if device in html["booting"]:
        return True
    if device in html["not_booting"]:
        if is_booting:
            print(device + ": still in 'not booting' section (if this is a"
                  " merge request, your device should be in the booting"
                  " section already)")
            return False
        return True
    if device in html["renamed"]:
        print(f"WARNING: {device} was renamed in the wiki")
        return True

    print(device + ": not in the wiki yet.")
    return False


def main():
    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--booting", help="devices must be in the upper table,"
                        " being in the 'not booting' table below is not"
                        " enough (all devices in pmaports master and stable"
                        " branches and should be in the upper table)",
                        action="store_true")
    parser.add_argument("--path", help="instead of downloading the devices"
                        " page from the wiki, use a local HTML file",
                        default=None)
    args = parser.parse_args()

    # Check all devices
    html = get_wiki_devices_html(args.path)
    html["renamed"] = get_wiki_renamed_devices_html()
    error = False
    for device in get_devices():
        if not check_device(device, html, args.booting):
            error = True

    # Ask to adjust the wiki
    if error:
        print("*** Wiki check failed!")
        print("Thank you for porting postmarketOS to a new device! \o/")
        print("")
        print("Now it's time to add some documentation:")
        print("1) Create a device specific wiki page as described here:")
        print("   <https://wiki.postmarketos.org/wiki/Help:Device_Page>")
        print("2) Set 'booting = yes' in the infobox of your device page.")
        print("3) Run these tests again with an empty commit in your MR:")
        print("   $ git commit --allow-empty -m 'run tests again'")
        print("")
        print("Please take the time to do these steps. It will make your")
        print("precious porting efforts visible for others, and allow them")
        print("not only to use what you have created, but also to build upon")
        print("it more easily. Many times one person did a port with basic")
        print("functionality, and then someone else jumped in and")
        print("contributed major new features.")
        return 1
    else:
        print("*** Wiki check successful!")
    return 0


sys.exit(main())
