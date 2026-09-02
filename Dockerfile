FROM php:8.4-cli-alpine

RUN apk add --no-cache \
        sqlite \
        sqlite-dev \
        oniguruma-dev \
        libzip-dev \
        icu-dev \
    && docker-php-ext-install \
        pdo_sqlite \
        mbstring \
        bcmath \
        pcntl \
        intl \
        zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist --no-autoloader

COPY . .
RUN composer dump-autoload --optimize \
    && mkdir -p database \
    && touch database/database.sqlite

EXPOSE 8080

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
