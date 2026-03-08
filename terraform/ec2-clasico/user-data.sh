#!/bin/bash

exec > /var/log/user-data.log 2>&1

apt update -y

apt install -y nginx php php-cli php-fpm php-mysql php-mbstring php-xml php-curl git unzip nodejs npm mariadb-server

systemctl enable nginx
systemctl start nginx

systemctl enable php8.1-fpm || systemctl enable php-fpm
systemctl start php8.1-fpm || systemctl start php-fpm

systemctl enable mariadb
systemctl start mariadb

mysql -e "CREATE DATABASE symfony_db;"

cd /usr/local/bin
curl -sS https://getcomposer.org/installer | php
mv composer.phar composer

cd /home/ubuntu || cd /home/ec2-user

git clone https://github.com/Alejandro-Polo/pruebadespliegue.git

cd pruebadespliegue/backend
composer install --no-interaction

php bin/console doctrine:migrations:migrate --no-interaction || true

cd ../frontend
npm install
npm run build

rm -rf /var/www/html/*
cp -r dist/* /var/www/html/

systemctl restart nginx