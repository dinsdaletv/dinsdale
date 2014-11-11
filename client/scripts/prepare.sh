#!/bin/bash

### default configuration (just the relevant parts)
VPN_KEY_FILE="/root/openvpn.key"
###


export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

umask 0077

if [ -e /etc/dinsdale_server.conf ]; then
	. /etc/dinsdale_server.conf
fi

echo "Checking and installing required packages..."

apt-get -y install openvpn ifenslave

if [ ! -e /etc/ppp/ip-up.d/01dinsdale ]; then
	ln -vs /opt/bond_dinsdale/client/hooks/ppp_up_hook.sh /etc/ppp/ip-up.d/01dinsdale
fi

if [ ! -e /etc/ppp/ip-down.d/01dinsdale ]; then
	ln -vs /opt/bond_dinsdale/client/hooks/ppp_down_hook.sh /etc/ppp/ip-down.d/01dinsdale
fi

if [ ! -e "$VPN_KEY_FILE" ]; then
	echo "ERROR: Could not find $VPN_KEY_FILE - this file is required to connect to the server!"
	echo "       You should copy it from the server once it is generated."
	exit 1
fi
