# Smart Router Project
# This project is used to build an OPENWRT router so to:
# 1. Able to Smart VPN based on the target websites
#	1.1 AutoVPN
#	1.2 VPNC
# 2. Able to be download machines by
#	2.1 Connect to a NFS driver
#	2.2 Xunlei remote download service
#	2.3 Or Opensource download service
# The build program currently is based on
############################################
#	TPLINK-WDR4310
############################################
# Author:	Jacob.Mee
# Email:	jacob@mitang.me
# Date:		March 17th, 2016
############################################

# Install ftp (optional):
opkg update
opkg install vsftpd openssh-sftp-server
/etc/init.d/vsftpd enable
/etc/init.d/vsftpd start

# Install VPNC
opkg install vpnc
vpnc /etc/vpnc/default.conf (copy)
Copy vpnc-script to /etc/vpnc, and set permission to execution

# dns
create etc/dns
copy two files - getlist.py (permission), and make_dnsmasq_conf

# Smartrouter
Copy the folder (smartrouter) under /etc

# Setcron
0 0 1 * * rm /etc/smartrouter/reconnect.log
0 0 * * 1 rm /etc/smartrouter/make_files.sh
0 5 * * * /sbin/reboot
*/5 * * * * sh /etc/smartrouter/checkpoint.sh

# Email
opkg install msmtp

# Install external disk & Samba
opkg install kmod-usb-storage block-mount kmod-fs-ext4
opkg install luci-app-samba
install fdisk/e2fsprogs (mkfs.ext3 /dev/sda1) if you want partition or format the disk
Goes System->Mount Point for setting up: enable fstab and samba

# If reinstall
opkg update
opkg vpnc msmtp kmod-usb-storage block-mount kmod-fs-ext4 luci-app-samba
[optional ]install fdisk/e2fsprogs (mkfs.ext3 /dev/sda1) if you want partition or format the disk
Reload the router configuration file
Copy vpnc & smart router files
Set vpnc/vpnc-script permission to 777
Reboot

# If New Setup without usb
opkg update
opkg vpnc msmtp vsftpd openssh-sftp-server curl
Reload the router configuration file
Copy vpnc & smart router files
Set vpnc/vpnc-script permission to 777
Reboot

echo "0">/sys/devices/virtual/net/br-lan/bridge/multicast_snooping
dd if=/dev/mtd5 of=/media/private/firmware.bin

# Image builder
make image PROFILE=TLWDR4300 PACKAGES="luci luci-app-firewall luci-i18n-english luci-lib-ipkg luci-lib-sys luci-proto-core luci-sgi-cgi luci-theme-base luci-theme-openwrt ip vpnc msmtp vsftpd openssh-sftp-server curl" FILES=files/

# Install NFS
Opkg install kmod-fs-nfs kmod-fs-nfs-common nfs-utils

# Reset upon on current Image
Change password
Update VPN configuration
Update /etc/hosts file
Mount the disk for xunlei
Install NFS: opkg install kmod-fs-nfs kmod-fs-nfs-common nfs-utils
mkdir /mnt/downloads
mount -t nfs 192.168.0.200:/volume1/downloads /mnt/downloads -o nolock
Install xunlei package
chmod 777 portal
./portal
