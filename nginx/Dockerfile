
FROM debian:bookworm-slim

ARG APP_UID=10001
ARG APP_GID=10001

# Instal Nginx dan curl untuk healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    curl \
    ca-certificates \
    && groupadd --gid ${APP_GID} nginx-app \
    && useradd --uid ${APP_UID} --gid ${APP_GID} \
       --no-create-home --shell /usr/sbin/nologin nginx-app \
    && mkdir -p /var/cache/nginx /var/lib/nginx \
       /var/log/nginx /tmp/nginx \
    && chown -R ${APP_UID}:${APP_GID} \
       /var/cache/nginx /var/lib/nginx \
       /var/log/nginx /tmp/nginx \
    && rm -rf /var/lib/apt/lists/*

# Gunakan konfigurasi Nginx milik project
COPY nginx.conf /etc/nginx/nginx.conf

# Jalankan sebagai user non-root
USER 10001:10001

# Port internal Nginx
EXPOSE 8080

# Periksa endpoint health
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -fsS http://127.0.0.1:8080/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
