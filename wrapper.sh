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

# filebrowser（/data，端口 8080，凭据走环境变量）
/usr/local/bin/filebrowser \
    --root /data \
    --port 8080 \
    --address 0.0.0.0 \
    --noauth 2>/tmp/filebrowser.log &

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
