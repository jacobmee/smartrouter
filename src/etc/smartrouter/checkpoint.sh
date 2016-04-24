#!/bin/bash

LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")

# See if the Shadowsocks alive
PID_F=`pgrep -f "ss-tunnel"`

# Use this flag to indicate the VPN status
ENABLED_SS=`sed -n 1p "/etc/smartrouter/ENABLED_SS"`

# See Shadowsocks is already started, and work properly
if [ $PID_F ] && [ $PID_F -gt 0 ]
then
	wget --spider --quiet --tries=1 --timeout=3 www.google.com
	if  [ "$?" == "0" ]
	then
		printout="Connnected successfully. Shadowsocks ID: ("$PID_F"),#("$ENABLED_SS")"
		logger -s $printout

		if [ $ENABLED_SS -gt 0 ]  
                then 
			let ENABLED_SS=0 # Reset VPN count
			echo $ENABLED_SS>/etc/smartrouter/ENABLED_SS
                        cat /etc/smartrouter/mails/enabled.mail | msmtp -a default admin@mitang.me 
                fi

		return
	else
		printout="["$LOGTIME"]: Shadowsocks alives, and killing #("$PID_F"),#("$ENABLED_SS")."
		logger -s $printout
		echo $printout >> /etc/smartrouter/reconnect.log
		/etc/init.d/shadowsocks stop
	fi
else
	# It means the Shadowsocks for some reason is just gone.
	printout="["$LOGTIME"]: Shadowsocks is not started, #("$ENABLED_SS")."
	logger -s $printout
	echo $printout >> /etc/smartrouter/reconnect.log
fi
        

# if it was good last time, notify me the SS is disabled.
if [ $ENABLED_SS -eq 0 ]
then
        printout="["$LOGTIME"]: Shadowsocks was good last time,#("$ENABLED_SS")." 
        logger -s $printout
        echo $printout >> /etc/smartrouter/reconnect.log
	cat /etc/smartrouter/mails/disabled.mail | msmtp -a default admin@mitang.me
fi

# Error+1
let ENABLED_SS=$ENABLED_SS+1  # Set Shadowsocks count one more
echo $ENABLED_SS>/etc/smartrouter/ENABLED_SS

# Restart DNSMASQ
# The reason why it needs to add the google DNS before DNSMASQ is because
# Maybe DNS is incorrect, so the adresses are resolved will lead to wrong address.
/etc/init.d/dnsmasq restart
logger -s " >>>>> DNSMASQ REFRESHED <<<<< "
	
# Start Shadowsocks
/etc/init.d/shadowsocks start
sleep 10
logger -s " >>>>> Shadowsocks Started <<<<< "

PID_F=`pgrep -f "ss-tunnel"`
	
# If restart Shadowsocks successful
if [ $PID_F ] && [ $PID_F -gt 0 ]
then
	# Test Google
	wget --spider --quiet --tries=1 --timeout=3 www.google.com
	if [ "$?" == "0" ]
	then
		printout="["$LOGTIME"]: Shadowsocks CONNECTED; #("$PID_F"),#("$ENABLED_SS")"
		logger -s $printout
		echo $printout >> /etc/smartrouter/reconnect.log
			
		if [ $ENABLED_SS -gt 0 ]  
                then 
			let ENABLED_SS=0 # Reset VPN count
			echo $ENABLED_SS>/etc/smartrouter/ENABLED_SS
                        cat /etc/smartrouter/mails/enabled.mail | msmtp -a default admin@mitang.me 
                fi         
        
	# Google is still failing, try to test Baidu
	else
		wget --spider --quiet --tries=1 --timeout=3 www.baidu.com
		if [ "$?" == "0" ]
		then
			printout="["$LOGTIME"]:Problems still exsits after Shadowsocks restarted; & Shadowsocks PID:#("$PID_F"),#("$ENABLED_SS")"
			logger -s $printout
			echo $printout >> /etc/smartrouter/reconnect.log
		else
			printout="["$LOGTIME"]:Network issue after Shadowsocks restarted. Rebooting... & Shadowsocks PID:#("$PID_F"),#("$ENABLED_SS")"
			logger -s $printout
			echo $printout >> /etc/smartrouter/reconnect.log
			cat /etc/smartrouter/mails/rebooted.mail | msmtp -a default admin@mitang.me
			sh /etc/smartrouter/x-reboot.sh
		fi
	fi
else 	# Shadowsocks can't be started, please check manually
	printout="["$LOGTIME"]: Couldn't connect Shadowsocks,#("$ENABLED_SS") please check the server."
	logger -s $printout
	cat /etc/smartrouter/mails/alert.mail | msmtp -a default admin@mitang.me
	echo $printout >> /etc/smartrouter/reconnect.log
fi
