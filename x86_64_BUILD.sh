# This build file is to setting up the files folder under ImageBuilder

# Get where the current bash file located
BASH_DIR=$(cd `dirname $0`; pwd)

# Define the destination
DEST=$BASH_DIR
SRC=$DEST/src/x86_64
BUILD_DEST=$BASH_DIR/../imageBuilder/openwrt-imagebuilder-19.07.2-x86-64.Linux-x86_64/

echo "# Clean and setup destination: "
echo "# ImageBuilder: "$BUILD_DEST
echo "# Target: "$DEST
rm -rf $BUILD_DEST/files
rm -rf $BUILD_DEST/bin
#rm -rf $DEST/bin

echo "# Copy neccessary files"
mkdir $BUILD_DEST/files
cp -r $SRC/* $BUILD_DEST/files/

echo "# Update packages"
#cp -r $DEST/packages/* $BUILD_DEST/packages/

echo "# Run the ImageBuilder"

# Build the image file
# It supports minimal set of openwrt with Shadowsocks, SFTP and NFS included.
# With 5M spaced needed.

cd $BUILD_DEST
make image PACKAGES="luci luci-theme-material wget vsftpd openssh-sftp-server" FILES=files/
# disable ChinaDNS luci-app-chinadns

echo "# Copy the target file into this Bin files"

mkdir bin
cp $BUILD_DEST/bin/targets/x86/64/**x86-64-combined* $DEST/bin/

echo "# Clean files"
make clean

# Go Back
cd $DEST

echo "##############################################"
echo "#    DONE, Please check the BIN folder!      #"
echo "##############################################"
