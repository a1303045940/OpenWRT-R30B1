#!/bin/bash

#删除冲突插件
rm -rf $(find ./feeds/luci/ -type d -regex ".*\(argon\|passwall\).*")
#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-design/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
echo "CONFIG_PACKAGE_luci-app-design-config=y" >> .config
#修改默认IP地址
#sed -i "s/192\.168\.[0-9]*\.[0-9]*/$OpenWrt_IP/g" ./package/base-files/files/bin/config_generate
#修改默认主机名
sed -i "s/hostname='.*'/hostname='PI_Zero'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate

#修改默认时间格式
sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $(find ./package/*/autocore/files/ -type f -name "index.htm")


cd ./package
#预置OpenClash内核和GEO数据

export OpenWrt_TARGET=armv7
export CORE_VER=https://raw.githubusercontent.com/vernesong/OpenClash/core/master/core_version
export CORE_TUN=https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux
export CORE_DEV=https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux
export CORE_MATE=https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux

export CORE_TYPE=$(echo $OpenWrt_TARGET | grep -iq "64" && echo "amd64" || echo "arm64")
export TUN_VER=$(curl -sfL $CORE_VER | sed -n "2{s/\r$//;p;q}")

export GEO_MMDB=https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb
export GEO_SITE=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
export GEO_IP=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat

cd ./feeds/smalllpackage/luci-app-openclash/root/etc/openclash

curl -fL -o ./Country.mmdb $GEO_MMDB
curl -fL -o ./GeoSite.dat $GEO_SITE
curl -fL -o ./GeoIP.dat $GEO_IP

mkdir ./core && cd ./core

curl -fL -o tun.gz "$CORE_TUN"-"$CORE_TYPE"-"$TUN_VER".gz
gzip -d tun.gz && mv tun clash_tun

curl -fL -o meta.tar.gz "$CORE_MATE"-"$CORE_TYPE".tar.gz
tar -zxf meta.tar.gz -O > meta && mv meta clash_meta

curl -fL -o dev.tar.gz "$CORE_DEV"-"$CORE_TYPE".tar.gz
tar -zxf dev.tar.gz

chmod +x clash* ; rm -rf *.gz