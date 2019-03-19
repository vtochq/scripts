#!/bin/bash
# (c) 2018, Alexander Kolesnikov
# IP ICMP simple monitoring script for SOHO use
#
# just put this script in crontab
# * * * * * /path/to/script/pinger.sh
#

# List of IP addresses for monitoring
declare -a IPS=(
192.168.1.1
192.168.1.4
192.168.1.5
192.168.1.10
192.168.1.11
192.168.1.16
)

# E-mail address for notifications
EMAIL="your@email.com"

##########

ALERT=""
for IP in "${IPS[@]}"
do
	if ! ping -c 1 $IP &> /dev/null
	then
		sleep 1
		# ping three times for... eliminate false triggering
		if ! ping -c 1 $IP &> /dev/null
	        then
			sleep 1
			if ! ping -c 1 $IP &> /dev/null
	                then
				ALERT="$ALERT$IP\n"
			fi
		fi
	fi
done

if [ -f "/tmp/pinger.hist" ];
then
	OLD_ALERT=$(cat /tmp/pinger.hist)
else
	touch /tmp/pinger.hist
	OLD_ALERT=""
fi

if [ "$ALERT" != "$OLD_ALERT" ];
then
	if [ ! -z "$ALERT" ];
        then
        	echo -e "Failed hosts:\n$ALERT"  | mail -s "Unavailble some hosts" $EMAIL
        else
                echo -e "All hosts availble."  | mail -s "Availble all hosts" $EMAIL
        fi
        echo "$ALERT" > /tmp/pinger.hist
fi
