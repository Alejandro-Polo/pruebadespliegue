#!/bin/bash

exec > /var/log/user-data.log 2>&1

yum update -y

yum install -y nginx
systemctl enable nginx
systemctl start nginx

amazon-linux-extras enable php8.1
yum clean metadata
yum install -y php php-cli php-fpm php-mysqlnd php-json php-mbstring php-xml git unzip

systemctl enable php-fpm
systemctl start php-fpm

yum install -y nodejs npm

cd /usr/local/bin
curl -sS https://getcomposer.org/installer | php
mv composer.phar composer

yum install -y mariadb-server

systemctl enable mariadb
systemctl start mariadb

sleep 10

mysql -e "CREATE DATABASE symfony_db;"

cd /home/ec2-user
git clone https://github.com/Alejandro-Polo/pruebadespliegue.git

cd pruebadespliegue/backend
composer install --no-interaction

php bin/console doctrine:migrations:migrate --no-interaction || true

cd ../frontend
npm install
npm run build

rm -rf /usr/share/nginx/html/*
cp -r dist/* /usr/share/nginx/html/

systemctl restart nginx