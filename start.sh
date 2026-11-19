#!/bin/bash
set -e

cd /var/www/html

# Generate app key if not set
php artisan key:generate --force

# Run migrations
php artisan migrate --force --no-interaction

# Seed database
php artisan db:seed --force --no-interaction || true

# Cache config
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Storage link
php artisan storage:link || true

# Fix permissions
chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /var/www/html/bootstrap/cache

# Start supervisor (manages php-fpm + nginx)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
