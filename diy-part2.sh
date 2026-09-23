#!/bin/bash
#
# diy-part2.sh — feeds install 之后、下载/编译之前执行，工作目录是 openwrt 源码根目录
#
# 路由器配置（含 WireGuard / ZeroTier / PPPoE / DDNS 凭据）不再存放在本仓库，
# 而是从私有仓库 mmc1987/Openwrt_etc 拉取后注入 openwrt/files/。
#
# 需要的 secret：FILES_TOKEN（本仓库 workflow 目前用 ACCESS_KEY 那个 PAT 提供）
#   推荐单独建 fine-grained token：GitHub → Settings → Developer settings →
#   Fine-grained tokens，只授予 Openwrt_etc 一个仓库、Contents: Read-only，
#   再加到 Actions → Secrets and variables → Actions → Repository secrets
# 未配置该 secret 时跳过注入，固件按 lede 默认配置出厂（不会导致编译失败）。
#

set -u

FILES_REPO="mmc1987/Openwrt_etc"
FILES_BRANCH="main"
FILES_SUBDIR="backup-OpenWrt"
CLONE_DIR=".etc-overlay-src"

# 不烧进固件的文件：账号口令哈希、SSH 主机私钥、uhttpd TLS 私钥。
# 这些应由刷机后的设备自行生成，否则镜像一旦外泄即可被离线破解/中间人。
SKIP_LIST="
/etc/passwd
/etc/shadow
/etc/group
/etc/dropbear/dropbear_rsa_host_key
/etc/dropbear/dropbear_ed25519_host_key
/etc/dropbear/dropbear_ecdsa_host_key
/etc/uhttpd.key
/etc/uhttpd.crt
"

log() { echo "[diy-part2] $*"; }

if [ -z "${FILES_TOKEN:-}" ]; then
  log "未设置 FILES_TOKEN secret，跳过配置注入"
  exit 0
fi

rm -rf "$CLONE_DIR"
if ! GIT_TERMINAL_PROMPT=0 git clone -q --depth 1 -b "$FILES_BRANCH" \
     "https://x-access-token:${FILES_TOKEN}@github.com/${FILES_REPO}.git" \
     "$CLONE_DIR" 2>/dev/null; then
  log "::error::克隆 ${FILES_REPO} 失败：FILES_TOKEN 无效、过期或权限不足"
  exit 1
fi

SRC_DIR="$CLONE_DIR/$FILES_SUBDIR"
if [ ! -d "$SRC_DIR/etc" ]; then
  log "::error::${FILES_REPO} 里找不到 ${FILES_SUBDIR}/etc"
  rm -rf "$CLONE_DIR"
  exit 1
fi

RSYNC_ARGS=()
for skip in $SKIP_LIST; do
  RSYNC_ARGS+=(--exclude "$skip")
done

mkdir -p files
if ! rsync -a "${RSYNC_ARGS[@]}" "$SRC_DIR"/ files/; then
  log "::error::注入配置失败（rsync 退出非 0），已中止而不是继续编译出厂版固件"
  rm -rf "$CLONE_DIR"
  exit 1
fi

log "已注入 $(find files -type f | wc -l | tr -d ' ') 个配置文件（源共 $(find "$SRC_DIR" -type f | wc -l | tr -d ' ') 个，口令哈希与主机密钥已按 SKIP_LIST 排除）"
log "全新固件未携带 root 口令，首次启动后需自行 passwd 设置"

rm -rf "$CLONE_DIR"
exit 0
