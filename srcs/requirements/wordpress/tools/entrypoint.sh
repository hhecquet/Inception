#!/bin/bash
set -eux

# This script runs every time the container starts.
# It checks if /var/www/html/wp-config.php exists. If not, we do a one-time install.

WEBROOT="/var/www/html"
if [ ! -f "$WEBROOT/wp-config.php" ]; then
  echo "[wordpress] First-boot: configuring wp-config.php and installing..."

  # Create wp-config.php. We rely on these env vars from .env (or docker-compose):
  #   * DB_HOST      (should be "mariadb")
  #   * MYSQL_DATABASE
  #   * MYSQL_USER
  #   * MYSQL_PASSWORD (via secret file)
  #   * WP_SITE_TITLE
  #   * WP_ADMIN_USER
  #   * WP_ADMIN_EMAIL
  #   * WP_ADMIN_PASSWORD (via secret file)

  # 1) Generate wp-config with correct DB settings:
  wp core config \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="mariadb" \
    --path="$WEBROOT" \
    --allow-root

  # 2) Run "wp core install"
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --path="$WEBROOT" \
    --skip-email \
    --allow-root

  echo "[wordpress] Site installed: https://${DOMAIN_NAME}"
fi

# Finally, exec php-fpm in the foreground so Docker can manage it:
exec php-fpm7.4 -F
