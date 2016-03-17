#!/bin/sh

IPS=`echo $1|tr "," "\n"`
#IPS="173.194.127.210"

echo "$IPS"

. /etc/smartrouter/autovpn.conf  
echo "$DEV"

# VPN is ready
if [ -n "$DEV" ] ;then

    # IP exists
    if [ -n "$IPS" ] ;then
        for ip in $IPS ;do
            ip route get $ip|grep -q $DEV
            if [ $? -ne 0 ];then
                ip route add $ip dev $DEV
                logger "$ip added to route table $DEV" 
                echo "$ip" >>$ROUTES
            fi
        done
    fi
    
else 
    #VPN is not ready#    
    echo "VPN is not ready, DEV is Null"
fi
