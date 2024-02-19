#!/bin/bash

#删除冲突插件
#rm -rf $(find ./feeds/luci/ -type d -regex ".*\(argon\|bootstrap\|openclash\).*")
#修改默认主题
sed -i "s/luci-theme-design/luci-theme-$openWRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$openWRT_IP/g" ./package/base-files/files/bin/config_generate
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$openWRT_NAME'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate

#修默认bash
sed -i 's/\/bin\/ash/\/bin\/bash/g' ./package/base-files/files/etc/passwd
#增加CPU温度显示
# sed -i '710 a <tr><td width="33%"><%:CPU Temperature%></td><td><%=luci.sys.exec("cut -c1-2 /sys/class/thermal/thermal_zone0/temp")%>&deg;C</td></tr>' /usr/lib/lua/luci/view/admin_status/index.htm
# sed -i 's/or "1"%>/or "1"%> ( <%=luci.sys.exec("expr `cat \/sys\/class\/thermal\/thermal_zone0\/temp` \/ 1000") or "?"%> \&#8451; ) /g' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

#增加Wifi温度显示
sed -i '/msgid "2.4G Temperature"/a msgstr "2.4G 温度"' ./package/lean/default-settings/po/zh-cn/default.po
sed -i '/msgid "5G Temperature"/a msgstr "5G 温度"' ./package/lean/default-settings/po/zh-cn/default.po

cat ./package/lean/default-settings/po/zh-cn/default.po

sed -i '/local cpu_usage =/a\
		local cpu_temp = luci.sys.exec("echo $(awk {'\''print sprintf(\"%.2f\",$1/1000)'\''} /sys/class/thermal/thermal_zone0/temp) ℃")\
    local wifi1_temp = luci.sys.exec("echo $(awk {'\''print sprintf(\"%.f\",$1/1000)'\''} /sys/class/ieee80211/phy0/hwmon1/temp1_input) ℃")\
    local wifi2_temp = luci.sys.exec("echo $(awk {'\''print sprintf(\"%.f\",$1/1000)'\''} /sys/class/ieee80211/phy1/hwmon2/temp1_input) ℃")' ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

sed -i '/cpuusage[[:space:]]* = cpu_usage,/a \
			cputemp     = cpu_temp,\
			wifi1temp   = wifi1_temp,\
			wifi2temp   = wifi2_temp,' ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

sed -i '/e.innerHTML = info.cpuusage;/a \
\
			if (e = document.getElementById('"'"'cputemp'"'"'))\
				e.innerHTML = info.cputemp;\
\
			if (e = document.getElementById('"'"'wifi1temp'"'"'))\
				e.innerHTML = info.wifi1temp;\
\
			if (e = document.getElementById('"'"'wifi2temp'"'"'))\
				e.innerHTML = info.wifi2temp;' ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

sed -i '/<tr><td width="33%"><%:CPU usage (%)%><\/td><td id="cpuusage">-<\/td><\/tr>/a \
        <tr>\
            <td width="33%"><%:Temperature%><\/td>\
            <td>\
                <a>(<%:CPU Temperature%><\/a>\
                <a id="cputemp"><\/a>\
                <a>)   (<%:2.4G Temperature%><\/a>\
                <a id="wifi1temp"><\/a>\
                <a>)   (<%:5G Temperature%><\/a>\
                <a id="wifi2temp"><\/a>\
                <a>)<\/a>\
            </td>\
        <\/tr>' ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

cat ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

#根据源码来修改
if [[ $WRT_URL == *"lede"* ]]; then
	LEDE_FILE=$(find ./package/lean/autocore/ -type f -name "index.htm")
	#修改默认时间格式
  sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M 星期%w")/g' $(find ./package/*/autocore/files/ -type f -name "index.htm")
fi

sed -i 's:/bin/ash:/bin/bash:g' /etc/passwd

#修改Tiny Filemanager汉化
if [ -d *"tinyfilemanager"* ]; then
	PO_FILE="./luci-app-tinyfilemanager/po/zh_Hans/tinyfilemanager.po"
	sed -i '/msgid "Tiny File Manager"/{n; s/msgstr.*/msgstr "文件管理器"/}' $PO_FILE
	sed -i 's/启用用户验证/用户验证/g;s/家目录/初始目录/g;s/Favicon 路径/收藏夹图标路径/g' $PO_FILE

	echo "tinyfilemanager date has been updated!"
fi