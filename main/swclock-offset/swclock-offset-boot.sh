#!/bin/sh

# This shell scripts reads the offset from the file and sets the 'swclock'.
#
# To keep the offset calculation simple, the epoch timestamp is used.
#
# The RTC is read from the sysfs node.
#
# To set the system time, command "date" is used. The "@" sign marks an
# epoch time format. As the "date" command offers no quiet option, the
# output is written to the null device.

rtc_sys_node="/sys/class/rtc/rtc0/since_epoch"
offset_file="/var/cache/swclock-offset/offset-storage"

# check presence of rtc sys node
if [ ! -f $rtc_sys_node ]; then
  exit 1
fi

# check presence of offset file
if [ ! -f $offset_file ]; then
  exit 2
fi

# calculate system time
hwclock_epoch=$(cat $rtc_sys_node)
offset_epoch=$(cat $offset_file)
swclock_epoch=$((hwclock_epoch + offset_epoch))

# set system time, dump output
date --utc --set=@$swclock_epoch > /dev/null
