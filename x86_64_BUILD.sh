# This build file is to setting up the files folder under ImageBuilder

# Get where the current bash file located
BASH_DIR=$(cd `dirname $0`; pwd)

# Define the destination
DEST=$BASH_DIR
SRC=$DEST/x86_64/src/
BUILD_DEST=$BASH_DIR/../lede

echo "# Clean and setup destination: "
echo "# ImageBuilder: "$BUILD_DEST
echo "# Target: "$DEST
rm -rf $BUILD_DEST/files
rm -rf $BUILD_DEST/bin
#rm -rf $DEST/bin

echo "# Copy neccessary files"
mkdir $BUILD_DEST/files
cp -r $SRC/* $BUILD_DEST/files/

make download -j5
make -j5 V=s

echo "# Copy the target file into this Bin files"
cp $BUILD_DEST/bin/targets/x86/64/openwrt-x86-64-combined-squashfs.vmdk $DEST/bin/NetAcceleratorII.vmdk

echo "# Clean files"
#make clean
cd $DEST

echo "##############################################"
echo "#    DONE, Please check the BIN folder!      #"
echo "##############################################"
