
FROM postgres:16-bookworm

ARG APP_UID=10001
ARG APP_GID=10001

# Ubah UID/GID user postgres menjadi 10001:10001
RUN set -eux; \
    groupmod --gid "${APP_GID}" postgres; \
    usermod --uid "${APP_UID}" --gid "${APP_GID}" postgres; \
    mkdir -p /var/run/postgresql /var/lib/postgresql; \
    chown -R "${APP_UID}:${APP_GID}" \
        /var/run/postgresql \
        /var/lib/postgresql; \
    chmod 3775 /var/run/postgresql

ENV PGDATA=/var/lib/postgresql/data

USER 10001:10001

EXPOSE 5432

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
    CMD ["pg_isready", "-h", "127.0.0.1", "-p", "5432"]
