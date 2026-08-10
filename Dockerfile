FROM node:22-bookworm-slim

ARG OPENCODE_VERSION=1.18.2

ENV DEBIAN_FRONTEND=noninteractive \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    OPENCODE_INSTALL_METHOD=npm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        git \
        gh \
        openssh-client \
        ripgrep \
        tini \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g "opencode-ai@${OPENCODE_VERSION}"

WORKDIR /app

COPY . /app

RUN chmod +x /app/entrypoint.sh \
    && mkdir -p /data

EXPOSE 4096

ENTRYPOINT ["/usr/bin/tini", "--", "/app/entrypoint.sh"]
