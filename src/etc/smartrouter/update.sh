#!/bin/bash

wget --spider --quiet --tries=1 --timeout=3 www.mitang.me
if  [ "$?" == "0" ]
then
	wget www.mitang.me/dnsmasq_list.conf -O /etc/smartrouter/dnsmasq_list.conf	
	mv /etc/smartrouter/dnsmasq_list.conf /etc/dnsmasq.d/

	#wget www.mitang.me/dnsmasq_apple.conf -O /etc/smartrouter/dnsmasq_apple.conf
	#mv /etc/smartrouter/dnsmasq_apple.conf /etc/dnsmasq.d/
fi
