#!/bin/bash

#Design Theme
git clone --depth=1 --single-branch --branch $(echo $openWRT_URL | grep -iq "lede" && echo "main" || echo "js") https://github.com/gngpp/luci-theme-design.git
git clone --depth=1 --single-branch https://github.com/gngpp/luci-app-design-config.git

#Argon Theme
#git clone --depth=1 --single-branch --branch $(echo $openWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-theme-argon.git
#git clone --depth=1 --single-branch https://github.com/jerrykuku/luci-app-argon-config.git

#Linkease
#git clone --depth=1 --single-branch https://github.com/linkease/istore.git
#git clone --depth=1 --single-branch https://github.com/linkease/nas-packages.git
#git clone --depth=1 --single-branch https://github.com/linkease/nas-packages-luci.git

#Open Clash
#git clone --depth=1 --single-branch --branch "dev" https://github.com/vernesong/OpenClash.git


#unblockneteasemusic
rm -rf ../../customfeeds/luci/applications/luci-app-unblockmusic
#git clone --depth=1 --single-branch --branch "master" https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git

#xlnetacc
#git clone --depth=1 --single-branch --branch "master" https://github.com/a7909a/luci-app-xlnetacc.git

#adguardhome
#git clone --depth=1 --single-branch --branch "master" https://github.com/rufengsuixing/luci-app-adguardhome.git

#vssr

# rm -rf package/helloworld
# git clone --depth=1 --single-branch --branch "main" https://github.com/fw876/helloworld.git
#git clone --depth=1 --single-branch https://github.com/xiaorouji/openwrt-passwall.git
#git clone --depth=1 --single-branch https://github.com/xiaorouji/openwrt-passwall-packages.git
#git clone --depth=1 --single-branch --branch "master" https://github.com/jerrykuku/lua-maxminddb.git


# rm -rf package/luci-app-tinyfilemanager
# git clone --depth=1 --single-branch "master" https://github.com/muink/luci-app-tinyfilemanager.git


#mosdns
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# #Open Clash
# git clone --depth=1 --single-branch --branch "dev" https://github.com/vernesong/OpenClash.git

# #预置OpenClash内核和GEO数据
# export CORE_VER=https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version
# export CORE_TUN=https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux
# export CORE_DEV=https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux
# export CORE_MATE=https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux

# export CORE_TYPE=$(echo $OWRT_TARGET | grep -Eiq "64|86" && echo "amd64" || echo "arm64")
# export TUN_VER=$(curl -sfL $CORE_VER | sed -n "2{s/\r$//;p;q}")

# export GEO_MMDB=https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb
# export GEO_SITE=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
# export GEO_IP=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat

# cd ./OpenClash/luci-app-openclash/root/etc/openclash

# curl -sfL -o ./Country.mmdb $GEO_MMDB
# curl -sfL -o ./GeoSite.dat $GEO_SITE
# curl -sfL -o ./GeoIP.dat $GEO_IP

# mkdir ./core && cd ./core

# curl -sfL -o ./tun.gz "$CORE_TUN"-"$CORE_TYPE"-"$TUN_VER".gz
# gzip -d ./tun.gz && mv ./tun ./clash_tun

# curl -sfL -o ./meta.tar.gz "$CORE_MATE"-"$CORE_TYPE".tar.gz
# tar -zxf ./meta.tar.gz && mv ./clash ./clash_meta

# curl -sfL -o ./dev.tar.gz "$CORE_DEV"-"$CORE_TYPE".tar.gz
# tar -zxf ./dev.tar.gz

# chmod +x ./clash* ; rm -rf ./*.gz



#!/bin/bash

#更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

	rm -rf $(find ../feeds/luci/ -type d -iname "*$PKG_NAME*" -prune)

	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	if [[ $PKG_SPECIAL == "pkg" ]]; then
		cp -rf $(find ./$REPO_NAME/ -type d -iname "*$PKG_NAME*" -prune) ./
		rm -rf ./$REPO_NAME
	elif [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

UPDATE_PACKAGE "tinyfilemanager" "muink/luci-app-tinyfilemanager" "master"

#修改Tiny Filemanager汉化
if [ -d *"tinyfilemanager"* ]; then
	PO_FILE="./luci-app-tinyfilemanager/po/zh_Hans/tinyfilemanager.po"
	sed -i '/msgid "Tiny File Manager"/{n; s/msgstr.*/msgstr "文件管理器"/}' $PO_FILE
	sed -i 's/启用用户验证/用户验证/g;s/家目录/初始目录/g;s/Favicon 路径/收藏夹图标路径/g' $PO_FILE

	echo "tinyfilemanager date has been updated!"
fi

#UPDATE_PACKAGE "design" "gngpp/luci-theme-design" "$([[ $WRT_URL == *"lede"* ]] && echo "main" || echo "js")"
#UPDATE_PACKAGE "design-config" "gngpp/luci-app-design-config" "master"

# UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "main"
# UPDATE_PACKAGE "passwall2" "xiaorouji/openwrt-passwall2" "main"
# UPDATE_PACKAGE "passwall-packages" "xiaorouji/openwrt-passwall-packages" "main"
UPDATE_PACKAGE "helloworld" "fw876/helloworld" "master"
# UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev"


