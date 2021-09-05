#!/bin/bash
BASH_DIR=$(cd `dirname $0`; pwd)

# Define the destination
DEST=${BASH_DIR}
SRC=${BASH_DIR}/src
BUILD_DEST=$BASH_DIR/../../lede

echo "current: "$DEST
echo "source: "$SRC
echo "build: "$BUILD_DEST

echo "Pull files from github"
cd $BUILD_DEST
git pull
cd $BUILD_DEST/package
git pull
cd $BUILD_DEST/package/openwrt-packages
git pull
cd $BUILD_DEST/package/small
git pull

cd $BUILD_DEST

echo "Start to update files from feed"
./scripts/feeds update -a && ./scripts/feeds install -a

echo "******Finished******"
