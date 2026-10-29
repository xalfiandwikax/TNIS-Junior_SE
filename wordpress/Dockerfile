
FROM php:8.2-apache-bookworm

ARG APP_UID=10001
ARG APP_GID=10001

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       ca-certificates \
       libpq-dev \
       tar \
    && docker-php-ext-install mysqli pgsql pdo_pgsql \
    && groupmod -g ${APP_GID} www-data \
    && usermod -u ${APP_UID} -g ${APP_GID} www-data \
    && mkdir -p /var/run/apache2 /var/lock/apache2 /tmp/apache2 \
    && chown -R ${APP_UID}:${APP_GID} \
       /var/run/apache2 /var/lock/apache2 /tmp/apache2 /var/www/html \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Install WordPress
RUN curl -fsSL https://wordpress.org/latest.tar.gz \
    | tar -xz --strip-components=1 \
    && chown -R ${APP_UID}:${APP_GID} /var/www/html

# Install PostgreSQL adapter PG4WP v3
RUN set -eux; \
    curl --retry 5 \
      --retry-all-errors \
      --retry-delay 3 \
      --connect-timeout 20 \
      --max-time 180 \ 
    -fsSL \
      https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/tags/v3.4.1.tar.gz \
      -o /tmp/pg4wp.tar.gz; \
    mkdir -p /tmp/pg4wp-src; \
    tar -xzf /tmp/pg4wp.tar.gz -C /tmp/pg4wp-src --strip-components=1; \
    test -f /tmp/pg4wp-src/pg4wp/db.php; \
    cp -a /tmp/pg4wp-src/pg4wp /var/www/html/wp-content/pg4wp; \
    cp /var/www/html/wp-content/pg4wp/db.php /var/www/html/wp-content/db.php; \
    rm -rf /tmp/pg4wp.tar.gz /tmp/pg4wp-src

# Create WordPress configuration using Compose environment variables
RUN cp wp-config-sample.php wp-config.php \
    && sed -i \
       -e "s/'database_name_here'/getenv('DB_NAME') ?: 'wordpress'/" \
       -e "s/'username_here'/getenv('DB_USER') ?: 'appuser'/" \
       -e "s/'password_here'/getenv('DB_PASSWORD') ?: ''/" \
       -e "s/'localhost'/getenv('DB_HOST') ?: 'postgres'/" \
       wp-config.php \
    && chown -R ${APP_UID}:${APP_GID} /var/www/html

# Set WordPress URL
RUN sed -i \
    "/require_once ABSPATH . 'wp-settings.php';/i define('WP_HOME', 'http://localhost:8080');\ndefine('WP_SITEURL', 'http://localhost:8080');\n" \
    /var/www/html/wp-config.php

# Apache listens on an unprivileged port
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
       /etc/apache2/envvars \
    && printf '\nServerName localhost\n' >> /etc/apache2/apache2.conf

USER 10001:10001

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=5s --start-period=45s --retries=5 \
    CMD curl -fsS http://127.0.0.1:8080/ || exit 1

CMD ["apache2-foreground"]
