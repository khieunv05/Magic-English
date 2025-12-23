FROM php:8.3-fpm

# System deps + PECL build
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    git curl zip unzip \
    libpq-dev \
    libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev \
    libonig-dev libzip-dev \
    mariadb-client \
    ca-certificates \
    $PHPIZE_DEPS; \
    rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
 && docker-php-ext-install -j"$(nproc)" gd zip pdo_mysql mbstring pcntl ftp exif

# redis ext
RUN set -eux; \
    pecl channel-update pecl.php.net || true; \
    printf "\n" | pecl install -o -f redis-6.0.2 \
    || ( pecl channel-update pecl.php.net || true; printf "\n" | pecl install -o -f redis-6.0.1 ); \
    docker-php-ext-enable redis; \
    rm -rf /tmp/pear ~/.pearrc

# Composer
RUN set -eux; \
    curl -sS https://getcomposer.org/installer | php -- \
      --install-dir=/usr/local/bin --filename=composer; \
    composer --version

WORKDIR /var/www/html

COPY .docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh