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

# This has included the SyncY solution to enable the Baidu sync
# Couple issues with this solution
# 1) Python takes 4M spaces
# 2) Performance could be worse
# 3) So far there are one issue are not resolved yet.

make image PROFILE=TLWDR4300 PACKAGES="luci luci-app-firewall luci-i18n-english luci-lib-ipkg luci-lib-sys luci-proto-core luci-sgi-cgi luci-theme-base luci-theme-openwrt ip vpnc msmtp kmod-fs-nfs kmod-fs-nfs-common nfs-utils vsftpd openssh-sftp-server kmod-nls-utf8 python python-curl SyncY-Python-luci" FILES=files/


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

