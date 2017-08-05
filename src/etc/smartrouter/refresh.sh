#!/usr/bin/env sh

# Get where the current bash file located
BASH_DIR=$(cd `dirname $0`; pwd)

wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > $BASH_DIR/ignore.list
rm $BASH_DIR/reconnect.log

#reboot
