# vnc-custom-sfo（定制版 noVNC 浏览器实例）

> 基于 novnc-slim（openbox+tint2+firefox-esr）定制，部署到 susanlee @ SFO。

## 定制点（vs 原 novnc-browser-susan）
1. **分辨率 1920x1080**（原 1024x768）
2. **中文环境**：zh_CN.UTF-8 locale + fonts-noto-cjk/wqy-zenhei + fcitx 输入法
3. **SSH 常驻**（2222，平台 TLS，root:${ROOT_PASS:-unikraft}，支持 PUBKEY）
4. **filebrowser**（8080，管 /data，浏览器可视化管理）
5. **永久存储**：卷 vnc-custom-data-sfo (1GiB) 挂 /data
6. 加了 curl/git/zip/unzip/file 常用工具

## 访问
- noVNC 桌面: https://<fqdn>/ （443:6080/tls+http）
- filebrowser: http://<fqdn>:8080/ （8080:8080/tcp，平台限制非 443 不能用 HTTP 模式）
- SSH（AI 管理通道，TLS 包装）:
  ssh -o ProxyCommand="openssl s_client -quiet -connect %h:2222 -servername %h" root@<fqdn>

## 部署
```
unikraft run --metro sfo -n vnc-custom-sfo -m 4G \
  -p 443:6080/tls+http -p 2222:2222/tls -p 8080:8080/tcp \
  -v vnc-custom-data-sfo:/data \
  -e "PUBKEY=$(cat ~/.ssh/id_ed25519.pub)" \
  --image susanlee/vnc-custom:latest
```

## 注意
- registry 配额 1GiB/org：镜像构建前先删旧 tag（workflow 已内置）
- filebrowser --noauth 仅限个人用，如需密码去 wrapper 里去掉 --noauth
- EROFS 只读 rootfs：重启后 rootfs 内的改动全丢，**重要数据必须放 /data**
