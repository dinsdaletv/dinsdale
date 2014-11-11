#!/bin/bash

### default configuration
BOND_IFACE="bond0"
BOND_IP="192.168.196.2"
BOND_NETMASK="255.255.255.0"
###


export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

umask 0077

if [ -e /etc/dinsdale_client.conf ]; then
	. /etc/dinsdale_client.conf
fi

echo "balance-rr 0" > /sys/class/net/$BOND_IFACE/bonding/mode
ifconfig $BOND_IFACE $BOND_IP netmask $BOND_NETMASK up

for number in 0 1 2 3 4 5 6 7 8 9; do
	TUN_IFACE="tap${number}"
	
	openvpn --mktun --dev $TUN_IFACE
	ip link set $TUN_IFACE down
	ifenslave bond0 $TUN_IFACE
	
	sleep 1
done
