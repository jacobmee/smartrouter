# This build file is to setting up the files folder under ImageBuilder

# Define the destination
BUILD_DEST=~/Workspace/OpenWrt-ImageBuilder-15.05.1-ar71xx-generic.Linux-x86_64

DEST=~/Workspace/git/repos/smartrouter

echo "# Clean and setup destination: "
echo "# ImageBuilder: "$BUILD_DEST
echo "# Target: "$DEST
rm -rf $BUILD_DEST/files
rm -rf $BUILD_DEST/bin
rm -rf $DEST/bin

echo "# Copy neccessary files"
mkdir $BUILD_DEST/files
cp -r $DEST/src/* $BUILD_DEST/files/

echo "# Update packages"
cp -r $DEST/packages/* $BUILD_DEST/packages/

echo "# Run the ImageBuilder"

# Build the image file
# It supports minimal set of openwrt with Shadowsocks, SFTP and NFS included.
# With 5M spaced needed.

cd $BUILD_DEST
make image PROFILE=TLWDR4300 PACKAGES="luci luci-app-firewall luci-theme-openwrt ip wget msmtp vsftpd openssh-sftp-server iptables-mod-nat-extra ipset libopenssl dnsmasq-full shadowsocks-libev -dnsmasq" FILES=files/


echo "# Copy the target file into this Bin files"
cd $DEST
mkdir bin
cp $BUILD_DEST/bin/ar71xx/*4310*squashfs* bin/

echo "# Clean files"
rm -rf $BUILD_DEST/files
rm -rf $BUILD_DEST/bin

echo "##############################################"
echo "#    DONE, Please check the BIN folder!      #"
echo "##############################################"

