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
git clone https://github.com/sbwml/luci-app-mosdns -b v5-lua package/mosdns
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

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

	rm -rf $(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune)

	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	if [[ $PKG_SPECIAL == "pkg" ]]; then
		cp -rf $(find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune) ./
		rm -rf ./$REPO_NAME/
	elif [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local PKG_MARK=${2:-not}
	local PKG_FILES=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/$PKG_NAME/Makefile")

	echo " "

	if [ -z "$PKG_FILES" ]; then
		echo "$PKG_NAME not found!"
		return
	fi

	echo "$PKG_NAME version update has started!"

	for PKG_FILE in $PKG_FILES; do
		local PKG_REPO=$(grep -Pho 'PKG_SOURCE_URL:=https://.*github.com/\K[^/]+/[^/]+(?=.*)' $PKG_FILE | head -n 1)
		local PKG_VER=$(curl -sL "https://api.github.com/repos/$PKG_REPO/releases" | jq -r "map(select(.prerelease|$PKG_MARK)) | first | .tag_name")
		local NEW_VER=$(echo $PKG_VER | sed "s/.*v//g; s/_/./g")
		local NEW_HASH=$(curl -sL "https://codeload.github.com/$PKG_REPO/tar.gz/$PKG_VER" | sha256sum | cut -b -64)
		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" "$PKG_FILE")

		echo "$OLD_VER $PKG_VER $NEW_VER $NEW_HASH"

		if [[ $NEW_VER =~ ^[0-9].* ]] && dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$PKG_FILE"
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$PKG_FILE"
			echo "$PKG_FILE version has been updated!"
		else
			echo "$PKG_FILE version is already the latest!"
		fi
	done
}



#UPDATE_PACKAGE "design" "gngpp/luci-theme-design" "$([[ $WRT_URL == *"lede"* ]] && echo "main" || echo "js")"
#UPDATE_PACKAGE "design-config" "gngpp/luci-app-design-config" "master"

# UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "main"
# UPDATE_PACKAGE "passwall2" "xiaorouji/openwrt-passwall2" "main"
# UPDATE_PACKAGE "passwall-packages" "xiaorouji/openwrt-passwall-packages" "main"
# UPDATE_PACKAGE "helloworld" "fw876/helloworld" "master"
# UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev"
UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"
UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "js"

