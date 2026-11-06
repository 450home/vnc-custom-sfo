#!/usr/bin/env bash

export HOME=/
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=high
export DISPLAY_NUM=1
export HEIGHT=1080
export WIDTH=1920
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

# 永久存储卷
mkdir -p /data/browser /data/downloads
[ -d /root/Downloads ] || ln -sf /data/downloads /root/Downloads 2>/dev/null || true

# 常驻 SSHD（2222）——AI/管理员管理通道
export PATH=$PATH:/usr/sbin
mkdir -p /run/sshd /root/.ssh
[ -n "$PUBKEY" ] && echo "$PUBKEY" >> /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys
echo "root:${ROOT_PASS:-unikraft}" | chpasswd 2>/dev/null || true
/usr/sbin/sshd -D -p 2222 &

# filebrowser（/data，端口 8080，用户名/密码认证；DB 在 /tmp——UKC 卷上 SQLite 文件锁 timeout，不能放 /data；用户每次 boot 由 env 重建）
FB_DB=/tmp/filebrowser.db
# 注意：此 filebrowser 版本没有 users upsert；密码必须 >=12 字符；每 boot 重建用户
[ -f "$FB_DB" ] || /usr/local/bin/filebrowser -d "$FB_DB" config init >/dev/null 2>&1
if ! /usr/local/bin/filebrowser -d "$FB_DB" users ls 2>/dev/null | grep -q "^1 "; then
    /usr/local/bin/filebrowser -d "$FB_DB" users add "${FILEBROWSER_USER:-admin}" "${FILEBROWSER_PASS:?need >=12 chars}" --perm.admin >/tmp/fb_user_err.log 2>&1 \
        || cat /tmp/fb_user_err.log >&2
fi
/usr/local/bin/filebrowser -d "$FB_DB" \
    --root /data \
    --port 8080 \
    --address 0.0.0.0 >/tmp/filebrowser.log 2>&1 &

if [ "$DEBUG_HOLD" = "1" ]; then
    echo "DEBUG_HOLD: container stays alive for SSH diagnosis"
    exec sleep infinity
fi

set -e
./start_all.sh

# noVNC
/opt/noVNC/utils/novnc_proxy \
    --vnc 0.0.0.0:5900 \
    --listen 6080 \
    --web /opt/noVNC
