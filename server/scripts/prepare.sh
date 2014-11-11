#!/bin/bash

### default configuration (just the relevant parts)
VPN_KEY_FILE="/root/openvpn2.key"
###


export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

umask 0077

if [ -e /etc/dinsdale_server.conf ]; then
	. /etc/dinsdale_server.conf
fi

echo "Checking and installing required packages..."

apt-get -y install openvpn ifenslave

if [ ! -e $VPN_KEY_FILE ]; then
	echo "Could not find key file - creating one for you..."
	openvpn --genkey --secret $VPN_KEY_FILE
	echo ""
	echo "  $VPN_KEY_FILE"
	echo ""
	echo "NOTE: this key must be copied to the client!"
fi
