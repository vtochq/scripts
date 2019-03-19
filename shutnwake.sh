#!/bin/bash 
# This script schedule BIOS alarm after 420 minutes and then shutdown your server/pc.
#
sh -c "echo 0 > /sys/class/rtc/rtc0/wakealarm" 
sh -c "echo `date '+%s' -d '+ 420 minutes'` > /sys/class/rtc/rtc0/wakealarm" 
/usr/sbin/shutdown -h now
