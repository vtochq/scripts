#!/bin/bash

declare -a IPS=(
192.168.1.4
192.168.1.5
)

EMAIL="vtochq@gmail.com"

ALERT=""
for IP in "${IPS[@]}"
do
	if ! ping -c 3 -W 1 $IP &> /dev/null
	then
		ALERT="$ALERT$IP\n"
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

