#!/bin/sh

if [ "$2" == "ACTIVATE" ]; then
    echo "AT+QGPS=1" | atinout - /dev/EG25.AT -
elif [ "$2" == "DEACTIVATE" ]; then
    echo "AT+QGPSEND" | atinout - /dev/EG25.AT -
else
    echo "Unhandled argument: $2"
    exit 1
fi
