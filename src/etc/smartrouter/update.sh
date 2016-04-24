#!/bin/bash

wget --spider --quiet --tries=1 --timeout=3 www.mitang.me
if  [ "$?" == "0" ]
then
	wget www.mitang.me/dnsmasq_list.conf -O /etc/smartrouter/dnsmasq_list.conf	
	cp /etc/smartrouter/dnsmasq_list.conf /etc/dnsmasq.d/
	rm /etc/smartrouter/dnsmasq_list.conf
fi
