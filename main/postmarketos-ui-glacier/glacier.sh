#!/bin/sh

export QT_IM_MODULE=qtvirtualkeyboard

# shellcheck disable=SC1091
. /usr/share/lipstick-glacier-home-qt5/nemovars.conf
/usr/bin/lipstick -platform eglfs -plugin evdevmouse evdevkeyboard evdevtablet
