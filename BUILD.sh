# This build file is to setting up the files folder under ImageBuilder

# Define the destination
BUILD_DEST=~/Workspace/ImageBuilder
DEST=$(pwd)

echo "# Clean and setup destination: "
echo "# ImageBuilder: "$BUILD_DEST
echo "# Target: "$DEST
rm -rf $BUILD_DEST/files
rm -rf $BUILD_DEST/bin
rm -rf $DEST/bin

echo "# Copy neccessary files"
mkdir $BUILD_DEST/files
cp -r src/* $BUILD_DEST/files/

echo "# Update packages"
cp -r packages/* $BUILD_DEST/packages/

echo "# Run the ImageBuilder"
cd $BUILD_DEST

# This version has included the Aria2. 
# The issue about Aria2 is that you'll need to open ports in the router to let external users to access the downloading service: 6800.
# Please be careful if you want to do that.
make image PROFILE=TLWDR4300 PACKAGES="luci luci-app-firewall luci-i18n-english luci-lib-ipkg luci-lib-sys luci-proto-core luci-sgi-cgi luci-theme-base luci-theme-openwrt ip vpnc msmtp kmod-fs-nfs kmod-fs-nfs-common nfs-utils vsftpd openssh-sftp-server aria2 luci-app-aria2" FILES=files/

echo "# Copy the target file into this Bin files"
cd $DEST
mkdir bin
cp $BUILD_DEST/bin/ar71xx/*4310*squashfs* bin/

echo "# Clean files"
rm -rf $BUILD_DEST/files
#rm -rf $BUILD_DEST/bin

echo "##############################################"
echo "#    DONE, Please check the BIN folder!      #"
echo "##############################################"

