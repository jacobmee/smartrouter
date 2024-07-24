1. Find right wrt to download
https://firmware-selector.openwrt.org/

2. Including the passwall repository

wget -O passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub
opkg-key add passwall.pub

read release arch << EOF
$(. /etc/openwrt_release ; echo ${DISTRIB_RELEASE%.*} $DISTRIB_ARCH)
EOF
for feed in passwall_luci passwall_packages passwall2; do
  echo "src/gz $feed https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/$feed" >> /etc/opkg/customfeeds.conf
done

3. update the opkg and install following package
passwall
-dnsmasq
dnsmasq-full
kmod-nft-tproxy
kmod-nft-socket

4. Argon
https://github.com/jerrykuku/luci-theme-argon/releases
