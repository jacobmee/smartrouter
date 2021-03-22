
sudo timedatectl set-timezone Asia/Shanghai
sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf

cd ..
git clone https://github.com/coolsnowwolf/lede
#git clone https://github.com/jacobmee/smartrouter

cd lede/package
git clone https://github.com/kenzok8/openwrt-packages
git clone https://github.com/kenzok8/small

cd ../..

cd smartrouter/x86_64
sh update.sh
