mount -t nfs 192.168.0.200:/volume1/downloads /mnt/downloads -o nolock
echo "-1">/etc/smartrouter/ENABLED_VPN
sh /etc/smartrouter/checkpoint.sh
