#!/bin/bash
rm /etc/smartrouter/dnsmasq_list.conf
rm /etc/dnsmasq.d/dnsmasq_list.conf

wget www.mitang.me/dnsmasq_list.conf -O /etc/smartrouter/dnsmasq_list.conf
cp /etc/smartrouter/dnsmasq_list.conf /etc/dnsmasq.d/
