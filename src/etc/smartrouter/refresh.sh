#!/usr/bin/env sh

wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/smartrouter/ignore.list
rm /etc/smartrouter/reconnect.log

#reboot
