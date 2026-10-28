
FROM postgres:16-bookworm

# Identitas user non-root untuk service database
ARG APP_UID=10001
ARG APP_GID=10001

# Siapkan direktori runtime dan data PostgreSQL
RUN set -eux; \
    mkdir -p /var/run/postgresql; \
    chown -R postgres:postgres /var/run/postgresql; \
    chmod 3775 /var/run/postgresql

# Data database disimpan pada direktori yang dapat dikelola
# oleh user postgres bawaan image resmi
ENV PGDATA=/var/lib/postgresql/data

# Image resmi PostgreSQL sudah menyediakan user postgres non-root.
# UID aktual akan diverifikasi saat container dijalankan.
USER postgres

EXPOSE 5432

# Periksa kesiapan server PostgreSQL
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
    CMD pg_isready -h 127.0.0.1 \
    -p 5432 \
    -U "$${POSTGRES_USER:-appuser}" \
    -d "$${POSTGRES_DB:-wordpress}" || exit 1
