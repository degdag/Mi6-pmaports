#!/bin/sh

rm -f /tmp/qt-WebBrowser-last-url.txt

crash_at_start=0
need_to_start=1

while [ "$need_to_start" -eq "1" ]; do

	START=$(date +%s)
	#Start the app with X11 and scale factor to 1.75
	QT_SCALE_FACTOR=1.75 QT_QPA_PLATFORM=xcb qtwebbrowser-bin >/tmp/qtwebbrowserlog 2>&1 
	END=$(date +%s)
	EXEC_TIME=$(( $END - $START ))

	#See if it crashed at startup or not
	if [ "$EXEC_TIME" -lt "17" ]; then
		crash_at_start=$(( crash_at_start + 1 ))
	else
		crash_at_start=0;
	fi

	#If the browser did not crash we do not need to restart it
	#It was closed intentionally by the user
	#If it crashed 4 times in a row at startup don't try again 
	#in order to avoid loops
	cat /tmp/qtwebbrowserlog | grep "Received signal"
	if [ "$?" -ne "0" ] || [ "$crash_at_start" -ge "4" ]; then
		need_to_start=0;
	fi
done
