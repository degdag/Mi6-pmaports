#!/bin/sh

# This shell scripts writes the offset between 'hwclock' and 'swclock'
# to a file.
#
# To keep the offset calculation simple, the epoch timestamp is used.
#
# The system time is read by command "date". The RTC is read from the
# sysfs node.

rtc_sys_node="/sys/class/rtc/rtc0/since_epoch"
offset_directory="/var/cache/swclock-offset"

# check presence of rtc sys node
if [ ! -f $rtc_sys_node ]; then
  exit 1
fi

# check presence of offset directory
if [ ! -d $offset_directory ]; then
  mkdir -p $offset_directory
fi

# calculate offset
swclock_epoch=$(date --utc +%s)
hwclock_epoch=$(cat $rtc_sys_node)
offset_epoch=$((swclock_epoch - hwclock_epoch))

# write offset file
echo $offset_epoch > $offset_directory/offset-storage
