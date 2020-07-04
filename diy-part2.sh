#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================
# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

gitcheckout() {
  git --git-dir=$1/.git --work-tree=$1 checkout .
}

patchdir() {
  for i in $1/*.patch; do
    patch -Ntp$2 < $i
  done
}

dir=`realpath \`dirname $0\``
device=$1
if [ "$device" = "" ]; then
  device=acrh17
fi

if [ ! -f "$dir/$device.config" ]; then
  echo device config file not found
  exit 1
fi

git clone --depth 1 https://github.com/yhfudev/openwrt-fcgiwrap.git $dir/feeds/fcgiwrap
mkdir $dir/feeds/fcgiwrap/patches
cp -f $dir/file/001-configure.ac.patch $dir/feeds/fcgiwrap/patches
pushd $dir/feeds/fcgiwrap
  # gitcheckout .
  patchdir ../../patches/fcgiwrap 4
popd

# 重置文件
# gitcheckout .
# gitcheckout feeds/luci

# 更新
# git pull

# 打补丁
patchdir $dir/patches 1
# cp -f $dir/file/include-target.mk include/target.mk
# cp -f $dir/file/target-linux-ipq40xx-Makefile target/linux/ipq40xx/Makefile

wget -q -O lede-cc689609d63c6e8d22ea965be2c8bfcb38b860d2.zip https://github.com/coolsnowwolf/lede/archive/cc689609d63c6e8d22ea965be2c8bfcb38b860d2.zip
unzip lede-cc689609d63c6e8d22ea965be2c8bfcb38b860d2.zip 'lede-cc689609d63c6e8d22ea965be2c8bfcb38b860d2/package/lean/luci-app-ssr-plus/*'
mv 'lede-cc689609d63c6e8d22ea965be2c8bfcb38b860d2/package/lean/luci-app-ssr-plus' package/lean

# 更新源
cat feeds.conf.default > feeds.conf
echo "src-link custom $dir/feeds" >> feeds.conf
./scripts/feeds update -a
./scripts/feeds install -a

# 文件
# cp -f $dir/file/localmirrors scripts/
cp -f $dir/file/0001-fstools-fix-libblkid-tiny-ntfs-uuid-detection.patch package/system/fstools/patches/

rm -f .config*
touch .config

cat $dir/common.config >> .config
cat $dir/$device.config >> .config

sed -i 's/^[ \t]*//g' .config
make defconfig
