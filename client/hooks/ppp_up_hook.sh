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

VPN_KEY_FILE="/root/openvpn.key"

TUN_IFACE="tap${number}"
TUN_SERVER="x.x.x.x"
TUN_PORT=$((2000 + number))
TUN_REMOTE="192.168.197.$((number * 4 + 1))"
TUN_LOCAL="192.168.197.$((number * 4 + 2))"
TUN_UP_HOOK="/opt/bond_dinsdale/client/hooks/tun_up_hook.sh"
TUN_DOWN_HOOK="/opt/bond_dinsdale/client/hooks/tun_down_hook.sh"

BOND_IFACE="bond0"

if [ -e /etc/dinsdale_client.conf ]; then
	. /etc/dinsdale_client.conf
fi


ip rule add from $PPP_LOCAL/32 lookup $table
ip route add default via $PPP_REMOTE dev $PPP_IFACE table $table

openvpn --mktun --dev $TUN_IFACE
ip link set $TUN_IFACE down
ifenslave $BOND_IFACE $TUN_IFACE

openvpn --secret $VPN_KEY_FILE \
	--dev $TUN_IFACE \
	--proto tcp-client \
	--local $PPP_LOCAL \
	--remote $TUN_SERVER \
	--ifconfig $TUN_LOCAL 255.255.255.254 \
	--lport $TUN_PORT \
	--rport $TUN_PORT \
	--persist-key \
	--persist-tun \
	--keepalive 1 10 \
	--cipher AES-256-CBC \
	--comp-lzo \
	--script-security 2 \
	--up $TUN_UP_HOOK \
	--up-delay \
	--up-restart \
	--down $TUN_DOWN_HOOK \
	--verb 3 >> /tmp/$TUN_IFACE.log 2>&1 &
TUN_PID=$!

echo $TUN_PID > /tmp/$TUN_IFACE.pid
