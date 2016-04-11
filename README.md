# Smart Router Project
This project is used to build an OPENWRT router so to:
* Smart VPN based on the target websites by AutoVPN with VPNC
* A download machines with Aria2
* Connect to a NFS driver

The build program currently is based on
**TPLINK-WDR4310**

* **Author**:	Jacob Mee
* **Email**:	jacob@mitang.me
* **Date**:		March 17th, 2016

## Components guides
Here is simple guideline to setup the router, and eventually I have built in into a firmware.
### Install ftp (optional):
```shell
opkg update
opkg install vsftpd openssh-sftp-server
/etc/init.d/vsftpd enable
/etc/init.d/vsftpd start
```

### Install VPNC
```shell
opkg install vpnc
vpnc /etc/vpnc/default.conf (copy)
Copy vpnc-script to /etc/vpnc, and set permission to execution
```

### Setcron
```shell
0 0 1 * * rm /etc/smartrouter/reconnect.log
0 0 * * 1 rm /etc/smartrouter/make_files.sh
0 5 * * * /sbin/reboot
*/5 * * * * sh /etc/smartrouter/checkpoint.sh
```

### Email
```shell
opkg install msmtp
```

### Install external disk & Samba
```shell
opkg install kmod-usb-storage block-mount kmod-fs-ext4
opkg install luci-app-samba
install fdisk/e2fsprogs (mkfs.ext3 /dev/sda1) if you want partition or format the disk
Goes System->Mount Point for setting up: enable fstab and samba
```

### Install NFS
```shell
Opkg install kmod-fs-nfs kmod-fs-nfs-common nfs-utils
```

## Fireware builder
Details please refer the BUILD.sh
```shell
make image PROFILE=TLWDR4300 PACKAGES="..." FILES=files/
```
