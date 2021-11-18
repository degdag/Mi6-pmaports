#!/bin/sh

export QT_IM_MODULE=qtvirtualkeyboard
export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_INTEGRATION=eglfs_kms

# Default locale, will be overwritten by the environment once the user
# has chosen their language in the setup screen
export LANG=en_GB.utf8

/usr/bin/asteroid-launcher
