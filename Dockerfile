FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=high
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh

# 安装依赖：X 栈 + openbox + 中文 + filebrowser
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    ca-certificates \
    locales \
    xserver-xorg-core \
    xauth \
    x11-xserver-utils \
    x11-utils \
    xvfb \
    xfonts-base \
    fonts-liberation \
    fonts-noto-cjk \
    fonts-wqy-zenhei \
    fcitx \
    fcitx-table \
    xterm \
    xdotool \
    scrot \
    openbox \
    x11vnc \
    tint2 \
    wget \
    curl \
    git \
    python3 \
    net-tools \
    iproute2 \
    openssh-server \
    openssh-client \
    procps \
    file \
    zip \
    unzip \
    firefox-esr && \
    sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    update-ca-certificates && \
    apt-get purge -y man-db 2>/dev/null || true; \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/* /usr/share/locale/* /var/cache/* /tmp/*

# noVNC via release tarballs
RUN wget -qO /tmp/novnc.tgz https://github.com/novnc/noVNC/archive/refs/tags/v1.5.0.tar.gz && \
    wget -qO /tmp/websockify.tgz https://github.com/novnc/websockify/archive/refs/tags/v0.12.0.tar.gz && \
    mkdir -p /opt/noVNC/utils/websockify && \
    tar -xzf /tmp/novnc.tgz -C /opt/noVNC --strip-components=1 && \
    tar -xzf /tmp/websockify.tgz -C /opt/noVNC/utils/websockify --strip-components=1 && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    rm -f /tmp/novnc.tgz /tmp/websockify.tgz

# filebrowser（单二进制，管 /data）
RUN wget -qO /usr/local/bin/filebrowser.tar.gz https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz && \
    tar -xzf /usr/local/bin/filebrowser.tar.gz -C /usr/local/bin filebrowser && \
    chmod +x /usr/local/bin/filebrowser && \
    rm -f /usr/local/bin/filebrowser.tar.gz

COPY ./image /
COPY --chmod=755 ./wrapper.sh /wrapper.sh

ENTRYPOINT [ "/wrapper.sh" ]
