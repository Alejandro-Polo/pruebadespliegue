#!/bin/bash

exec > /var/log/user-data.log 2>&1


dnf update -y

dnf install -y nginx
systemctl enable nginx
systemctl start nginx

dnf install -y php php-cli php-fpm php-mysqlnd php-json php-mbstring php-xml git unzip

systemctl enable php-fpm
systemctl start php-fpm

dnf install -y nodejs npm

cd /usr/local/bin
curl -sS https://getcomposer.org/installer | php
mv composer.phar composer

dnf install -y mariadb105-server

systemctl enable mariadb
systemctl start mariadb

sleep 10

mysql -e "CREATE DATABASE symfony_db;"

cd /home/ec2-user

git clone https://github.com/Alejandro-Polo/pruebadespliegue.git

cd pruebadespliegue

cd backend
composer install --no-interaction

php bin/console doctrine:migrations:migrate --no-interaction || true

cd ../frontend
npm install
npm run build

rm -rf /usr/share/nginx/html/*
cp -r dist/* /usr/share/nginx/html/

systemctl restart nginx
