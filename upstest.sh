#!/bin/bash
# Script for testing and reporting UPS battery
#
MSG="BEFORE TEST\n$(/usr/bin/upsc mustek1400)"
MSG="$MSG\n\nTEST STATUS: $(/usr/bin/upscmd -u upsmon -p Passw0rd  mustek1400 test.battery.start.quick 2>&1)"
sleep 2
MSG="$MSG\n\nTEST\n$(/usr/bin/upsc mustek1400)"
sleep 10
MSG="$MSG\n\nAFTER TEST\n$(/usr/bin/upsc mustek1400)"
echo -e "$MSG" | mail -s "vHOME UPS Test" your@email.com
