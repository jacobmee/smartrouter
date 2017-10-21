#!/usr/bin/env sh

LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")
LOGMINUTE=$(date +"%M")
D_MIN=60
# Get where the current bash file located
BASH_DIR=$(cd `dirname $0`; pwd)

# See if the Shadowsocks alive
PID_F=`pgrep -f "ss-redir"`

# Use this flag to indicate the VPN status
ENABLED_SS=`sed -n 1p "$BASH_DIR/ENABLED_SS"`

print_log () {
	logger -s $1
	
	if [ "$2" = true ]; then
		echo "["$LOGTIME"] "$1 >> $BASH_DIR/reconnect.log
	fi

	if [ "$3" ]; then
		cat $BASH_DIR/mails/$3 | msmtp -a default admin@mitang.me
	fi
}

ping_address () {

	ping -c 1 -W 10 -w 10 $1 >/dev/null
	ret=$?

	#echo ping result $ret
	if [ $ret -eq 0 ]; then
		if [ "$(($LOGMINUTE%$D_MIN))" == "0" ]; then		
			print_log "[Watchdog] $1: PASS"
		fi
	else
		print_log "[Watchdog] $1: FAILED" true
		#From: Router.Home <router@mitang.me>
		#Subject:[Router] Watchdog alert!
		if [ "$(($LOGMINUTE%$D_MIN))" == "0" ]; then
			printf "From: Router.Home <router@mitang.me>\nSubject: [Router] Watchdog [$1] is not accessible!\n\nAlert!\n[$1] is not accessible at this moment, please check.\n" | msmtp -a default admin@mitang.me
		fi
		sleep 1
	fi
}

# Watch dogs important servers.
ping_address "R6900"
ping_address "Tanghut"
ping_address "Walkhutair"
ping_address "MiTangDS"
ping_address "Redsea-Balling"
#ping_address "FakeMachine"

# DDNS heartbeats update
if [ "$(($LOGMINUTE%$D_MIN))" == "0" ]; then
	wget --quiet -O $BASH_DIR/ddns.log http://jacobmee:jac0bm11@ddns.oray.com/ph/update?hostname=jacobmee.eicp.net
	ddns=$(cat "$BASH_DIR/ddns.log")

	case $ddns in
		*nochg*)
			print_log "[DDNS]: $ddns" ;;
		*)
			print_log "[DDNS]: $ddns" ;;
	esac

fi

# Shadowsocks checking
# See Shadowsocks is already started, and work properly
if [ $PID_F ] && [ $PID_F -gt 0 ]; then

	# Check if it can access SS server, or give up.
	wget --no-check-certificate --spider --quiet --tries=3 --timeout=3 www.mitang.me
        if  [ "$?" == "0" ]; then

		wget --no-check-certificate --spider --quiet --tries=3 --timeout=3 www.youtube.com
		RETURNCODE=$?

		# This is first time it works again.
		if  [ "$RETURNCODE" == "0" ]; then
			# Reset Error counts
			if [ $ENABLED_SS -gt 0 ]; then
				let ENABLED_SS=0
				echo $ENABLED_SS>$BASH_DIR/ENABLED_SS
				print_log "[SHADOWSOCKS]: Back to work. #ID: ("$PID_F"),("$ENABLED_SS")"
			else
				# Logger every #60 minutes
				if [ "$(($LOGMINUTE%$D_MIN))" == "0" ]; then
					print_log "[SHADOWSOCKS]: Hourly checkpoint passed. #ID: ("$PID_F"),("$ENABLED_SS")"
				fi
			fi

			# Checkpoint passed successfully.
			return 0
		fi

		wget --spider --quiet --tries=3 --timeout=3 www.baidu.com
		print_log "[SHADOWSOCKS]: I'm alive. However, Baidu gave me #"$?" & Youtube gave me #"$RETURNCODE". #ID: ("$PID_F"),("$ENABLED_SS")" true

		# Error+1
		let ENABLED_SS=$ENABLED_SS+1  # Set Shadowsocks count one more
		echo $ENABLED_SS>$BASH_DIR/ENABLED_SS

		# Don't necessary to restart if errors < 5 times
		if  [ $ENABLED_SS -lt 6 ]; then
			return 0
		fi

		print_log "[SHADOWSOCKS & NETWORK]: The services are restarting... #E: ("$ENABLED_SS")"

		print_log "[SHADOWSOCKS & NETWORK]: Stopping Shadowsocks"
		/etc/init.d/shadowsocks-libev stop
		sleep 3

		print_log "[SHADOWSOCKS & NETWORK]: Refreshing the network"
		/etc/init.d/network restart
		sleep 20

		print_log "[SHADOWSOCKS & NETWORK]: Starting Shadowsocks"
		/etc/init.d/shadowsocks-libev start
		sleep 5

		# Double check if everything is fine
		PID_F=`pgrep -f "ss-redir"`
		if [ $PID_F ] && [ $PID_F -gt 0 ]; then

			wget --no-check-certificate --spider --quiet --tries=3 --timeout=3 www.youtube.com
			if [ "$?" == "0" ]; then
				print_log "[SHADOWSOCKS]: Successfully NEW connected. #ID: ("$PID_F"),("$ENABLED_SS")" true "enabled.mail"
			
				if [ $ENABLED_SS -gt 0 ]; then
					let ENABLED_SS=0 # Reset VPN count
					echo $ENABLED_SS>$BASH_DIR/ENABLED_SS
				fi
        
			# Try Baidu
			else
				wget --spider --quiet --tries=3 --timeout=3 www.baidu.com
				if [ "$?" == "0" ]; then
					print_log "[SHADOWSOCKS]: Still can't access Youtube after restarting the service. #ID: ("$PID_F"),("$ENABLED_SS")" true
				else
					print_log "[SHADOWSOCKS]: Still everything is down after restarting the service. #ID: ("$PID_F"),("$ENABLED_SS")" true
				fi

				if  [ $ENABLED_SS -gt 60 ]; then
					print_log "[SHADOWSOCKS]: Counting 60 (3 hours) already, rebooting the router. #ID: ("$PID_F"),("$ENABLED_SS")" true "rebooted.mail"
					reboot
				fi
			fi
		else 	# Shadowsocks can't be started, please check manually
			print_log "[SHADOWSOCKS]:  Couldn't start the service. #("$ENABLED_SS") please check manually." true "alert.mail"
	
		fi

	else 
		print_log "[SHADOWSOCKS]: Can't even access Shadowsocks Server. #ID: ("$PID_F"),("$ENABLED_SS")"	
	fi

else
	print_log "[SHADOWSOCKS]: Shadowsocks is disabled."
fi
