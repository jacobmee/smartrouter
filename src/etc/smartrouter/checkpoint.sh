#!/bin/bash

LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")
LOGMINUTE=$(date +"%M")

# See if the Shadowsocks alive
PID_F=`pgrep -f "ss-redir"`

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

# DDNS heartbeats
if [ "$(($LOGMINUTE%60))" == "0" ]
then
	wget -O /etc/smartrouter/ddns.log http://jacobmee:jac0bm11@ddns.oray.com/ph/update?hostname=jacobmee.eicp.net
	ddns=$(cat "/etc/smartrouter/ddns.log")

	case $ddns in
		*nochg*)
			;;
		*)
			print_log "[DDNS]: Heartbeating: $ddns" ;;
	esac

fi

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
			if [ "$(($LOGMINUTE%60))" == "0" ]
			then
				print_log "[SHADOWSOCKS]: Hourly checkpoint passed. #ID: ("$PID_F"),("$ENABLED_SS")"
			#else
				#print_log "[SHADOWSOCKS]: Checkpoint passed." false
			fi
		fi

		# Checkpoint passed successfully.
		return 0
	else
		# 4 means "Network Failure"
		if  [ "$RETURNCODE" == "4" ]
		then
			wget --spider --quiet --tries=3 --timeout=3 www.baidu.com
			print_log "[SHADOWSOCKS]: I'm alive. However, Baidu gave me #"$?" & Google gave me #"$RETURNCODE". #ID: ("$PID_F"),("$ENABLED_SS")" true
			# Unnecessary to restart the shadowsocks, maybe a random issue
			return 0
		else
			print_log "[SHADOWSOCKS]: I'm alive, but Google gave me #"$RETURNCODE". #ID: ("$PID_F"),("$ENABLED_SS")" true
			# This requires a restart.
		fi
	fi
fi

# Error+1
let ENABLED_SS=$ENABLED_SS+1  # Set Shadowsocks count one more
echo $ENABLED_SS>/etc/smartrouter/ENABLED_SS

print_log "[SHADOWSOCKS & DNSMASQ]: The services are restarting..."
# Restart DNSMASQ for refresh
/etc/init.d/dnsmasq restart
# Start Shadowsocks
/etc/init.d/shadowsocks-libev restart
sleep 2

PID_F=`pgrep -f "ss-redir"`
# If restart Shadowsocks successful
if [ $PID_F ] && [ $PID_F -gt 0 ]
then
	# Test Google
	wget --spider --quiet --tries=3 --timeout=3 www.google.com
	if [ "$?" == "0" ]
	then
		print_log "[SHADOWSOCKS]: Successfully connected. #ID: ("$PID_F"),("$ENABLED_SS")" true "enabled.mail"
			
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
			print_log "[SHADOWSOCKS]: Problems still exists after restarting the service. #ID: ("$PID_F"),("$ENABLED_SS")" true
		else
			print_log "[SHADOWSOCKS]: Network issue after restarting the service, so require reboot?. #ID: ("$PID_F"),("$ENABLED_SS")" true "alert.mail"
		fi
	fi
else 	# Shadowsocks can't be started, please check manually
	print_log "[SHADOWSOCKS]:  Couldn't start the service. #("$ENABLED_SS") please check manually." true "alert.mail"
fi