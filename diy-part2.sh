#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate



# git clone "https://${REPO_TOKEN}@github.com/mmc1987/Openwrt_etc.git" || error_exit "克隆仓库失败"
# log "私有仓库克隆完成"

# # 检查源目录和目标目录
# check_directory "Openwrt_etc/backup-OpenWrt"
# create_directory "files"

# # 复制文件
# log "开始复制文件"
# cp -rv Openwrt_etc/backup-OpenWrt/* files/ || error_exit "复制文件失败"
# log "文件复制完成"

# # 清理临时文件
# log "清理临时文件"
# rm -rf Openwrt_etc
# log "清理完成"
