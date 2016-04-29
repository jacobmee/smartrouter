#!/bin/bash

LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")

# See if the Shadowsocks alive
PID_F=`pgrep -f "ss-tunnel"`

# Use this flag to indicate the VPN status
ENABLED_SS=`sed -n 1p "/etc/smartrouter/ENABLED_SS"`

print_log () {
	logger -s $1
	
	if [ "$2" = true ]
	then
		echo "["$LOGTIME"] "$1 >> /etc/smartrouter/reconnect.log
	fi

	if [ "$3" ]
	then
		cat /etc/smartrouter/mails/$3 | msmtp -a default admin@mitang.me
	fi
}


# See Shadowsocks is already started, and work properly
if [ $PID_F ] && [ $PID_F -gt 0 ]
then
	wget --spider --quiet --tries=3 --timeout=3 www.google.com
	RETURNCODE=$?
	if  [ "$RETURNCODE" == "0" ]
	then
		
		# This is first time it works again.
		if [ $ENABLED_SS -gt 0 ]  
                then 
			let ENABLED_SS=0 # Reset VPN count
			echo $ENABLED_SS>/etc/smartrouter/ENABLED_SS
			print_log "[SHADOWSOCKS]: NEW Connected. #ID: ("$PID_F"),("$ENABLED_SS")" true "enabled.mail"
               	else
			# Logger every #60 minutes
			LOGMINUTE=$(date +"%M")
			if [ "$(($LOGMINUTE%60))" == "0" ]
			then
				print_log "[SHADOWSOCKS]: Hourly checkpoint passed. #ID: ("$PID_F"),("$ENABLED_SS")"
			fi
		fi
	# If it gives error
	else
		# 4 means "Network Failure"
		if  [ "$RETURNCODE" == "4" ]
		then
			wget --spider --quiet --tries=3 --timeout=3 www.baidu.com
			print_log "[SHADOWSOCKS]: I'm alive. However, Baidu gave me #"$?" & Google gave me #"$RETURNCODE". #ID: ("$PID_F"),("$ENABLED_SS")" true
		else
			print_log "[SHADOWSOCKS]: I'm alive. But Google gave me #"$RETURNCODE". #ID: ("$PID_F"),("$ENABLED_SS")" true
		fi
	fi
	
	# So far looks unessary to restart the shadowsocks
	# /etc/init.d/shadowsocks stop
	return 0

else
	# It means the Shadowsocks for some reason is just gone.  It requires restart.
	print_log "[SHADOWSOCKS]: The service is not started. #("$ENABLED_SS")." true
fi

# if it was good last time, notify me the SS is disabled.
if [ $ENABLED_SS -eq 0 ]
then
        print_log "[SHADOWSOCKS]: The service sas good last time. #("$ENABLED_SS")." true "disabled.mail" 
fi

# Error+1
let ENABLED_SS=$ENABLED_SS+1  # Set Shadowsocks count one more
echo $ENABLED_SS>/etc/smartrouter/ENABLED_SS

# Restart DNSMASQ
# The reason why it needs to add the google DNS before DNSMASQ is because
# Maybe DNS is incorrect, so the adresses are resolved will lead to wrong address.

# Disable the refresh because looks uneccessary
# /etc/init.d/dnsmasq restart
# logger -s " >>>>> DNSMASQ REFRESHED <<<<< "
	
# Start Shadowsocks
/etc/init.d/shadowsocks start
sleep 10
PID_F=`pgrep -f "ss-tunnel"`
print_log "[SHADOWSOCKS]: The service is started. #ID: ("$PID_F"),("$ENABLED_SS")"


# If restart Shadowsocks successful
if [ $PID_F ] && [ $PID_F -gt 0 ]
then
	# Test Google
	wget --spider --quiet --tries=3 --timeout=3 www.google.com
	if [ "$?" == "0" ]
	then
		print_log "[SHADOWSOCKS]: NEW Connected. #ID: ("$PID_F"),("$ENABLED_SS")" true "enabled.mail"
			
		if [ $ENABLED_SS -gt 0 ]  
                then 
			let ENABLED_SS=0 # Reset VPN count
			echo $ENABLED_SS>/etc/smartrouter/ENABLED_SS
                fi         
        
	# Google is still failing, try to test Baidu
	else
		wget --spider --quiet --tries=3 --timeout=3 www.baidu.com
		if [ "$?" == "0" ]
		then
			print_log "[SHADOWSOCKS]: Problems still exsits after restarting the service. #ID: ("$PID_F"),("$ENABLED_SS")" true
		else
			print_log "[SHADOWSOCKS]: Network issue after restarting the service, so rebooting. #ID: ("$PID_F"),("$ENABLED_SS")" true "rebooted.mail"
			sh /etc/smartrouter/x-reboot.sh
		fi
	fi
else 	# Shadowsocks can't be started, please check manually
	print_log "[SHADOWSOCKS]:  Couldn't start the service. #("$ENABLED_SS") please check manually." true "alert.mail"
fi
