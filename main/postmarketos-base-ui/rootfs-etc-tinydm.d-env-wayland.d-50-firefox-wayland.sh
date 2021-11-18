#!/bin/sh

# Firefox does not enable Wayland by default on Phosh, so we need to force it.
# GDK_BACKEND=wayland is not used as it causes issues (chiefly, makes
# gsd-xsettings crash) and is not necessary with GTK apps.
export MOZ_ENABLE_WAYLAND=1
