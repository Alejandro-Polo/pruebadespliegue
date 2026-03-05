FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    git unzip libpq-dev libonig-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www

COPY . .

RUN curl -sS https://getcomposer.org/installer | php \
    && php composer.phar install

EXPOSE 8000

CMD php -S 0.0.0.0:8000 -t public