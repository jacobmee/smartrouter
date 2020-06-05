DATE=`date "+%y%m%d"`
TIME=`date "+%H:%M:%S"`
HOUR=`date "+%H"`
echo "date: $DATE, time: $TIME, hour: $HOUR"

# if the hours meet

#Run the script to test
FILE="/etc/smartrouter/record.log"
echo -n $TIME" <=> " >> $FILE
wget https://downloads.openwrt.org/releases/19.07.3/targets/x86/64/openwrt-19.07.3-x86-64-rootfs-ext4.img.gz 2>&1 | grep -o "[0-9.]\+ [KM]*B/s" >> $FILE
rm open*.img.gz
