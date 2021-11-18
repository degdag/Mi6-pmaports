#!/bin/ash

cmd=$( echo $0 | awk '{i=split($0,a,"/"); print a[i]}' )

function adjust_keypad_bl {
	for i in $(seq 1 6); do
    		echo $1 > /sys/class/leds/lp5523\:kb$i/brightness
	done
}

case $cmd in
	KP_SLIDE_OPEN)
		adjust_keypad_bl 255	
		;;
	KP_SLIDE_CLOSE)
		adjust_keypad_bl 0
		;;
	CAM_BTN_DWN)
		echo "Not implemented yet"
		;;
	CAM_BTN_UP)
		echo "Not implemented yet"
		;;
	CAM_FOCUS_DWN)
		echo "Not implemented yet"
		;;
	CAM_FOCUS_UP)
		echo "Not implemented yet"
		;;
	CAM_LID_CLOSE)
		echo "Not implemented yet"
		;;
	CAM_LID_OPEN)
		echo "Not implemented yet"
		;;
	FRNT_PRXY_OFF)
		echo "Not implemented yet"
		;;
	FRNT_PRXY_ON)
		echo "Not implemented yet"
		;;
	KP_SLIDE_CLOSE)
		echo "Not implemented yet"
		;;
	KP_SLIDE_OPEN)
		echo "Not implemented yet"
		;;
	SCRNLCK_DWN)
		echo "Not implemented yet"
		;;
	SCRNLCK_UP)
		echo "Not implemented yet"
		;;
        HEADPHONE_INSERT)
                alsactl restore -f /var/lib/alsa/asound.state.headset
                ;;
        HEADPHONE_REMOVE)
                alsactl restore -f /var/lib/alsa/asound.state.speakers
                ;;
        MICROPHONE_INSERT)
                echo "Not implemented yet"
                ;;
        MICROPHONE_REMOVE)
                echo "Not implemented yet"
                ;;
        PWR_BTN_DWN)
                echo "Not implemented yet"
                ;;
        PWR_BTN_UP)
                echo "Not implemented yet"
                ;;
        VIDEOOUT_INSERT)
                echo "Not implemented yet"
                ;;
        VIDEOOUT_REMOVE)
                echo "Not implemented yet"
                ;;
        VOL_DWN)
                echo "Not implemented yet"
                ;;
        VOL_UP)
                echo "Not implemented yet"
                ;;
	*)
		echo "Unknown event"
		exit 1
		;;
esac


