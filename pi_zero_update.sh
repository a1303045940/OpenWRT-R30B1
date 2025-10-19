#!/bin/bash

#删除冲突插件
rm -rf $(find ./feeds/luci/ -type d -regex ".*\(argon\|passwall\).*")
#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-design/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
echo "CONFIG_PACKAGE_luci-app-design-config=y" >> .config
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/192.168.6.1/g" ./package/base-files/files/bin/config_generate
#修改默认主机名
sed -i "s/hostname='.*'/hostname='PI_Zero'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate

#修改默认时间格式
sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $(find ./package/*/autocore/files/ -type f -name "index.htm")

