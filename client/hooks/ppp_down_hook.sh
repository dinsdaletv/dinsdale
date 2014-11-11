#!/bin/bash

# args:
# ppp0 /dev/ttyUSB0 9600 10.1.1.1 10.2.2.2

# env:
# PPP_IFACE=ppp0
# PPP_TTY=/dev/ttyUSB0
# PPP_SPEED=9600
# PPP_REMOTE=10.2.2.2
# PPP_LOCAL=10.1.1.1
# PPPD_PID=10003

export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

umask 0077

number=`echo "$PPP_IFACE" | grep -Eo '([0-9]+)$'`
table=$((100 + number))

TUN_IFACE="tap${number}"
BOND_IFACE="bond0"

if [ -e /etc/dinsdale_client.conf ]; then
	. /etc/dinsdale_client.conf
fi


TUN_PID=`cat /tmp/$TUN_IFACE.pid 2>/dev/null`

if [ "$TUN_PID" != "" ]; then
	kill $TUN_PID
	sleep 3
fi

ip route del default via $PPP_REMOTE dev $PPP_IFACE table $table
ip rule del from $PPP_LOCAL/32 lookup $table
