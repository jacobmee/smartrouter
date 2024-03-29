# This build file is to setting up the files folder under ImageBuilder

# Get where the current bash file located
BASH_DIR=$(cd `dirname $0`; pwd)

# Define the destination
DEST=$BASH_DIR/..
SRC=$BASH_DIR/src
BUILD_DEST=$BASH_DIR/../../lede
DATE=`date +"%Y%m%d"`

echo "# Clean and setup destination: "
echo "# ImageBuilder: "$BUILD_DEST
echo "# Target: "$DEST
rm -rf $BUILD_DEST/files
rm -rf $BUILD_DEST/bin
#rm -rf $DEST/bin

echo "# Copy neccessary files"
mkdir $BUILD_DEST/files
cp -r $SRC/* $BUILD_DEST/files/


echo "Start to BUILD"
cd $BUILD_DEST/

make download -j5
make -j5 V=s

echo "# Copy the target file into this Bin files"
cp $BUILD_DEST/bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk $DEST/bin/NetAccelerator_Lede_x86_64_$DATE.vmdk

echo "# Clean files"
#make clean
cd $DEST

echo "##############################################"
echo "#    DONE, Please check the BIN folder!      #"
echo "##############################################"
