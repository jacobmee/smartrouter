#!/bin/bash

wget --spider --quiet --tries=1 --timeout=3 www.mitang.me
if  [ "$?" == "0" ]
then
	wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > ignore.list
fi
