
FROM php:8.2-apache-bookworm

ARG APP_UID=10001
ARG APP_GID=10001

# Instal dependency dan ekstensi PostgreSQL untuk PHP
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    && docker-php-ext-install pgsql pdo_pgsql \
    && groupmod -g ${APP_GID} www-data \
    && usermod -u ${APP_UID} -g ${APP_GID} www-data \
    && mkdir -p /var/run/apache2 /var/lock/apache2 /tmp/apache2 \
    && chown -R ${APP_UID}:${APP_GID} \
       /var/run/apache2 /var/lock/apache2 /tmp/apache2 \
       /var/www/html \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Unduh WordPress resmi
RUN curl -fsSL https://wordpress.org/latest.tar.gz \
    | tar -xz --strip-components=1 \
    && chown -R 10001:10001 /var/www/html

# Pindahkan Apache ke port 8080
# dan arahkan file runtime ke direktori yang dapat ditulis
RUN sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' \
       /etc/apache2/sites-available/000-default.conf \
    && sed -i 's|^export APACHE_PID_FILE=.*|export APACHE_PID_FILE=/tmp/apache2/apache2.pid|' \
       /etc/apache2/envvars \
    && sed -i 's|^export APACHE_RUN_DIR=.*|export APACHE_RUN_DIR=/tmp/apache2|' \
       /etc/apache2/envvars \
    && sed -i 's|^export APACHE_LOCK_DIR=.*|export APACHE_LOCK_DIR=/tmp/apache2|' \
       /etc/apache2/envvars \
    && sed -i 's|^export APACHE_RUN_USER=.*|export APACHE_RUN_USER=www-data|' \
       /etc/apache2/envvars \
    && sed -i 's|^export APACHE_RUN_GROUP=.*|export APACHE_RUN_GROUP=www-data|' \
       /etc/apache2/envvars

# Jalankan Apache dan PHP dengan user non-root
USER 10001:10001

EXPOSE 8080

# Periksa respons HTTP WordPress
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=5 \
    CMD curl -fsS http://127.0.0.1:8080/ || exit 1

CMD ["apache2-foreground"]
