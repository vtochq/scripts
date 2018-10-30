#!/bin/sh
# Dynamic DNS based on BIND9 and shell script in cron.
# (c) Alexander Kolesnikov (vtochq@gmail.com) , 2016
# Edit parameters before use. On server side configure zone and allow updates of one A-record by secure key.
# Put this script in cron and run every 5 minutes.
#
TTL=120
SERVER=100.100.100.101 # IP address of Your public DNS server
HOSTNAME=host.domain.com. # Hostname (subdomain). With dot at the end.
ZONE=domain.com.
WORKDIR=/root
KEYFILE=$WORKDIR/Kdomain.kz.+137+53822.private # BIND9 key file
EMAIL=Your@email.com # email for notifications
#
#
new_ip_address=$(curl -s http://v4.ipv6-test.com/api/myip.php)
new_ip_address=${new_ip_address/ /}

if [ "$new_ip_address" != "" ] && [ "$new_ip_address" != *"DOCTYPE"* ]; then

	#echo $new_ip_address

	if [ -e $WORKDIR/current_ip ]; then
		CURRENT_IP=`cat $WORKDIR/current_ip`

		#echo $CURRENT_IP
	else
            	logger -s "current_ip file don't exist. Creating."
                echo $new_ip_address > $WORKDIR/current_ip
		CURRENT_IP="0.0.0.0"
        fi

		if [ $CURRENT_IP != $new_ip_address ]; then

			#echo "IP changed"

			echo "$HOSTNAME IP changed. Old: $CURRENT_IP; New: $new_ip_address" | mail -s "$HOSTNAME ip changed" $EMAIL
			logger -s "$HOSTNAME IP changed. Old: $CURRENT_IP; New: $new_ip_address"
			echo $new_ip_address > $WORKDIR/current_ip

			nsupdate -v -k $KEYFILE << EOF
server $SERVER
zone $ZONE
update delete $HOSTNAME A
update add $HOSTNAME $TTL A $new_ip_address
send
EOF

			echo $new_ip_address > $WORKDIR/current_ip
		else
			logger -s "IP not changed."
		fi
else
	logger -s "IP address don't received form external service."

fi
