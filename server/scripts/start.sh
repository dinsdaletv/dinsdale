#!/bin/bash

### default configuration
WAN_IFACE="eth0"
WAN_IP="auto"

BOND_IFACE="bond0"
BOND_IP="192.168.196.1"
BOND_NETMASK="255.255.255.0"

VPN_KEY_FILE="/root/openvpn.key"
###


export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

umask 0077

if [ -e /etc/dinsdale_server.conf ]; then
	. /etc/dinsdale_server.conf
fi

if [ "$WAN_IP" == "auto" ]; then
	WAN_IP=`ifconfig $WAN_IFACE | grep 'inet addr' | grep -Eo 'inet addr:[^ ]+' | cut -d : -f 2`
fi

echo "balance-rr 0" > /sys/class/net/$BOND_IFACE/bonding/mode
ifconfig $BOND_IFACE $BOND_IP netmask $BOND_NETMASK up

for number in 0 1 2 3 4 5 6 7 8 9; do
	TUN_IFACE="tap${number}"
	TUN_PORT="$((2000 + number))"
	
	openvpn --mktun --dev $TUN_IFACE
	ip link set $TUN_IFACE down
	ifenslave bond0 $TUN_IFACE
	
	openvpn --secret $VPN_KEY_FILE \
		--script-security 2 \
		--local $WAN_IP \
		--dev $TUN_IFACE \
		--ifconfig 192.168.197.$((number * 4 + 1)) 255.255.255.252 \
		--proto tcp-server \
		--lport $TUN_PORT \
		--rport $TUN_PORT \
		--verb 3 \
		--cipher AES-256-CBC \
		--comp-lzo \
		--persist-tun \
		--keepalive 1 10 >> /tmp/$TUN_IFACE.log 2>&1 &
	
	TUN_PID=$!
	echo $TUN_PID > /tmp/$TUN_IFACE.pid
	
	sleep 1
done
