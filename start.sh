#!/bin/sh
set -e

cd /var/www/html

# Generate app key if not set
php artisan key:generate --force

# Run migrations
php artisan migrate --force

# Seed database
php artisan db:seed --force

# Cache configs
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Create storage link
php artisan storage:link

# Start supervisor (nginx + php-fpm)
exec /usr/bin/supervisord -c /etc/supervisord.conf
