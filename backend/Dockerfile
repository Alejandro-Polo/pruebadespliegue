FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    git unzip libpq-dev libonig-dev libzip-dev curl \
    && docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www

COPY . .

# instalar composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN composer install

EXPOSE 8000

CMD sleep 15 && php bin/console doctrine:migrations:migrate --no-interaction && php -S 0.0.0.0:8000 -t public