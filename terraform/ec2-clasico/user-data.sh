#!/bin/bash

yum update -y

yum install -y nginx
systemctl start nginx
systemctl enable nginx

yum install -y php php-cli php-fpm php-mysqlnd git unzip

systemctl start php-fpm
systemctl enable php-fpm

yum install -y nodejs npm

cd /home/ec2-user
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
mv composer.phar /usr/local/bin/composer

yum install -y mariadb105-server
systemctl start mariadb
systemctl enable mariadb

mysql -e "CREATE DATABASE symfony_db;"

cd /home/ec2-user
git clone https://github.com/Alejandro-Polo/pruebadespliegue.git
cd pruebadespliegue

cd backend
composer install

php bin/console doctrine:migrations:migrate --no-interaction

cd ../frontend
npm install
npm run build

rm -rf /usr/share/nginx/html/*
cp -r dist/* /usr/share/nginx/html/

systemctl restart nginx