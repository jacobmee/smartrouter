#!/bin/sh

USER="jacobmee"                                                                  
PASS="jac0bm11"                                                            
DOMAIN="jacobmee.eicp.net"
UPDATING_URL="http://${USER}:${PASS}@ddns.oray.com:80/ph/update?hostname=${DOMAIN}"
CURRENT_IP_URL="http://ddns.oray.com/checkip"
IP_FILE="/tmp/ddns"
IPCHECK_FILE="/tmp/ddnscheck"


if [ -f ${IP_FILE} ]; then

	# Getting old ip from file
	#echo `cat ${IP_FILE}`
	old_ip=`cat ${IP_FILE} | egrep "good|nochg" | awk '{print $2}'`
	echo "old_ip is: ${old_ip}"
	
	# Getting new ip from URL
	curl -o ${IPCHECK_FILE} -s ${CURRENT_IP_URL}
	
	# echo `cat ${IPCHECK_FILE}`
	current_ip=`cat ${IPCHECK_FILE} | grep "Address: " | awk -F "<" '{ print $7}' | awk '{ print $4}'` 
	echo "current ip: ${current_ip}" 
	
	# If they are the same, do exit
        if [ "${old_ip}" = "${current_ip}" ]; then
		echo `cat ${IP_FILE}`
        	exit
        fi
fi
  
# New IP found, then do the update                                                  
curl -o ${IP_FILE} -s ${UPDATING_URL}
new_ip=`cat ${IP_FILE} | grep "good" | awk '{print $2}'`
if [ ${new_ip} ]; then
	logger -s "DDNS updated to ORAY: ${new_ip}"
else
	echo `cat ${IP_FILE}`
fi
