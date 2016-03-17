#!/bin/bash

ping=`ping -c 3 www.twitter.com | grep 'received'  | awk -F',' '{print$2}' | awk '{print$1}'`
min=`date | awk '{print$4}' | awk -F ':' '{print$2}'`
PID_F=`pgrep -f "vpnc /etc/vpnc/default.conf"`

ENABLED_VPN=`sed -n 1p "/etc/smartrouter/ENABLED_VPN"`

# ==== See VPNC is already started, and work properly ====
if [ $PID_F ] && [ $PID_F -gt 0 ] && [ $ping -eq 3 ]
then
	if [ $min -lt 5 ]
	then
		printout="Access Twitter successfully. VPNC ID: ("$PID_F"),#("$ENABLED_VPN")"
		logger -s $printout
	fi
elif [ $PID_F ] && [ $PID_F -gt 0 ] && [ $ping -gt 0 ]
then
	logger -s "Access Twitter successfully, but Ping:("$ping") is low; VPNC PID:#("$PID_F"),#("$ENABLED_VPN")"
else

	# ==================== Restart the VPNC ====================================
	if [ $PID_F ] && [ $PID_F -gt 0 ]
	then
		printout=`date`" +++++ VPNC alives, and killing #("$PID_F"),#("$ENABLED_VPN") right now. +++++"
		logger -s $printout
		echo $printout >> /etc/smartrouter/reconnect.log
		kill $PID_F
		sleep 5
	else
		printout=`date`": VPNC is gone,#("$ENABLED_VPN")."                                               
	        logger -s $printout                                                                               
	        echo $printout >> /etc/smartrouter/reconnect.log  
	fi
	
	# if it was good last time
	if [ $ENABLED_VPN -eq 0 ]                                                                                                                           
        then    
        	printout=`date`": VPNC was good last time,#("$ENABLED_VPN")."                                               
        	logger -s $printout                                                                               
        	echo $printout >> /etc/smartrouter/reconnect.log 
        	                                
        	cat /etc/smartrouter/mails/disabled.mail | msmtp -a default admin@mitang.me
        fi  
                                                        
	let ENABLED_VPN=$ENABLED_VPN+1  # Set VPN count one more
	echo $ENABLED_VPN>/etc/smartrouter/ENABLED_VPN
		
	vpnc /etc/vpnc/default.conf
	
	# To add google DNS
	route add 8.8.8.8 dev tun0

        # uPNP bug fix for WIFI
        echo "0">/sys/devices/virtual/net/br-lan/bridge/multicast_snooping
        
   	# ==================== Restart DNSMASQ ====================================
        /etc/init.d/dnsmasq restart
        logger -s " >>>>> DNSMASQ REFRESHED <<<<< "
	
	PID_F=`pgrep -f "vpnc /etc/vpnc/default.conf"`
	
	if [ $PID_F ] && [ $PID_F -gt 0 ] # ===== IF Restart VPNC successful ==========
	then
		# ==================== TEST BAIDU & TWITTER====================================
		pingb=`ping -c 3 www.baidu.com | grep 'received'  | awk -F',' '{print$2}' | awk '{print$1}'`
		pingt=`ping -c 3 www.twitter.com | grep 'received'  | awk -F',' '{print$2}' | awk '{print$1}'`
		if [ $pingt -gt 0 ] && [ $pingb -gt 0 ]
		then
			printout=`date`": VPNC CONNECTED; #("$PID_F"),#("$ENABLED_VPN")"
			logger -s $printout
			echo $printout >> /etc/smartrouter/reconnect.log
			
			if [ $ENABLED_VPN -gt 0 ]                                                                                                                              
                        then             
                        	cat /etc/smartrouter/mails/enabled.mail | msmtp -a default admin@mitang.me                                           
                        fi                                                                                                                                                  
                        
                        let ENABLED_VPN=0 # Reset VPN count
			echo $ENABLED_VPN>/etc/smartrouter/ENABLED_VPN                                                                                                 		
		else
			printout=`date`":Problems after VPNC restarted; Twitter:("$pingt"), Baidu:("$pingb"). Rebooting... & VPNC PID:#("$PID_F"),#("$ENABLED_VPN")"
			logger -s $printout
			echo $printout >> /etc/smartrouter/reconnect.log
			cat /etc/smartrouter/mails/rebooted.mail | msmtp -a default admin@mitang.me
			reboot
		fi
	else 	# =======  VPNC CANN'T STARTED, NEED TO LOOK AT IT MANUALLY ===========
		printout=`date`": Couldn't connect VPNC,#("$ENABLED_VPN") please check the server."
		logger -s $printout
		# cat /etc/smartrouter/mails/alert.mail | msmtp -a default admin@mitang.me
		echo $printout >> /etc/smartrouter/reconnect.log
	fi
fi