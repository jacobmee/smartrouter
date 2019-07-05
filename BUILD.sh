 # This build file is to setting up the files folder under ImageBuilder

# Get where the current bash file located
BASH_DIR=$(cd `dirname $0`; pwd)

# Define the destination
DEST=$BASH_DIR
BUILD_DEST=$BASH_DIR/../Router.LinkSys.WRT1900ACS2/openwrt-imagebuilder-18.06.4-mvebu-cortexa9.Linux-x86_64/

echo "# Clean and setup destination: "
echo "# ImageBuilder: "$BUILD_DEST
echo "# Target: "$DEST
rm -rf $BUILD_DEST/files
rm -rf $BUILD_DEST/bin
#rm -rf $DEST/bin

echo "# Copy neccessary files"
mkdir $BUILD_DEST/files
cp -r $DEST/src/* $BUILD_DEST/files/

echo "# Update packages"
#cp -r $DEST/packages/* $BUILD_DEST/packages/

echo "# Run the ImageBuilder"

# Build the image file
# It supports minimal set of openwrt with Shadowsocks, SFTP and NFS included.
# With 5M spaced needed.

cd $BUILD_DEST
make image PROFILE=linksys-wrt1900acs PACKAGES="luci luci-theme-material wget msmtp vsftpd openssh-sftp-server iptables-mod-nat-extra ipset libopenssl -dnsmasq dnsmasq-full shadowsocks-libev luci-app-shadowsocks ChinaDNS luci-app-chinadns simple-obfs" FILES=files/
# disable ChinaDNS luci-app-chinadns

echo "# Copy the target file into this Bin files"
cd $DEST
mkdir bin
cp $BUILD_DEST/build_dir/target-arm_cortex-a9+vfpv3_musl_eabi/linux-mvebu_cortexa9/tmp/**wrt1900acs* bin/

echo "# Clean files"
rm -rf re$BUILD_DEST/files
rm -rf $BUILD_DEST/bin

echo "##############################################"
echo "#    DONE, Please check the BIN folder!      #"
echo "##############################################"


