# Smart Router Project

This project is used to build an OPENWRT router so to:
* **Smart Router** based on the target websites by **Shadowsocks** with wget heartbeat


The build program is for **LINKSYS WRT1900ACS.V2** based on **Openwrt CC-15.05.1**.  The current wireless driver is **mwlwifi_3.18.23+10.3.0.17-20160531-1_mvebu**, but it needs to be updated to mwlwifi_10.3.0.18-20160804_mvebu for V2.


* **Author**:	Jacob Mee
* **Email**:	jacob@mitang.me
* **Date**:	Sept 10th, 2016

## Components guides
* luci luci-app-firewall luci-theme-openwrt 
* ip 
* wget msmtp vsftpd openssh-sftp-server 
* iptables-mod-nat-extra ipset libopenssl 
* dnsmasq-full -dnsmasq
* shadowsocks-libev 

