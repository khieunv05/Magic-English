#!/bin/sh
set -eu

echo "[entrypoint] working dir: $(pwd)"
cd /var/www/html

# ensure writable dirs
mkdir -p storage/app storage/framework/{cache,sessions,views} bootstrap/cache
# Trong WSL (ext4) chown/chmod sẽ có tác dụng thực
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rwX storage bootstrap/cache || true

if [ -f "composer.json" ]; then
  if [ ! -d "vendor" ]; then
    echo "[entrypoint] vendor/ not found → composer install..."
    COMPOSER_PROCESS_TIMEOUT=2000 composer install --no-interaction --prefer-dist --no-progress
  else
    echo "[entrypoint] vendor/ exists → dump autoload..."
    composer dump-autoload -o 2>&1 | grep -v "Could not scan" || true
  fi
else
  echo "[entrypoint] composer.json không tồn tại → bỏ qua composer"
fi

if [ -f "./artisan" ]; then
  echo "[entrypoint] ensure APP_KEY..."
  php artisan key:generate --force || true
fi

echo "[entrypoint] start php-fpm..."
exec php-fpm
