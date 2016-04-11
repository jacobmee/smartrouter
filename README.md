# Smart Router Project

This project is used to build an OPENWRT router so to:
*1. Able to Smart VPN based on the target websites
*	1.1 AutoVPN
*	1.2 VPNC
* 2. Able to be download machines by
*	2.1 Connect to a NFS driver
*	2.2 Xunlei remote download service
*	2.3 Or Opensource download service
* The build program currently is based on


**	TPLINK-WDR4310 **

**Author**:	Jacob Mee
**Email**:	jacob@mitang.me
**Date**:		March 17th, 2016

* Install ftp (optional):
opkg update
opkg install vsftpd openssh-sftp-server
/etc/init.d/vsftpd enable
/etc/init.d/vsftpd start

* Install VPNC
opkg install vpnc
vpnc /etc/vpnc/default.conf (copy)
Copy vpnc-script to /etc/vpnc, and set permission to execution

* dns
create etc/dns
copy two files - getlist.py (permission), and make_dnsmasq_conf

* Smartrouter
Copy the folder (smartrouter) under /etc

* Setcron
0 0 1 * * rm /etc/smartrouter/reconnect.log
0 0 * * 1 rm /etc/smartrouter/make_files.sh
0 5 * * * /sbin/reboot
*/5 * * * * sh /etc/smartrouter/checkpoint.sh

* Email
opkg install msmtp

* Install external disk & Samba
opkg install kmod-usb-storage block-mount kmod-fs-ext4
opkg install luci-app-samba
install fdisk/e2fsprogs (mkfs.ext3 /dev/sda1) if you want partition or format the disk
Goes System->Mount Point for setting up: enable fstab and samba

* Install NFS
Opkg install kmod-fs-nfs kmod-fs-nfs-common nfs-utils

