# Smart Router Project
This project is used to build an OPENWRT router so to:
* Smart VPN based on the target websites by AutoVPN with VPNC
* A download machines
*	Connect to a NFS driver

The build program is for **TPLINK-WDR4310** based on **Openwrt CC-15.05.1**

* **Author**:	Jacob Mee
* **Email**:	jacob@mitang.me
* **Date**:		March 17th, 2016

## Components guides
* luci luci-app-firewall luci-theme-openwrt 
* ip 
* wget msmtp vsftpd openssh-sftp-server 
* iptables-mod-nat-extra ipset libopenssl 
* dnsmasq-full -dnsmasq
* shadowsocks-libev 

