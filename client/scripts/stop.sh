#!/bin/bash

export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

for number in 0 1 2 3 4 5 6 7 8 9; do
	TUN_IFACE="tap${number}"
	
	ifenslave -d bond0 $TUN_IFACE
	openvpn --rmtun --dev $TUN_IFACE
done

ifconfig bond0 down
