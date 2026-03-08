#!/bin/bash

yum update -y

amazon-linux-extras install nginx1 -y
systemctl start nginx
systemctl enable nginx

amazon-linux-extras enable php8.2
yum install php php-cli php-fpm php-mysqlnd git unzip -y

systemctl start php-fpm
systemctl enable php-fpm

curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install nodejs -y

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
mv composer.phar /usr/local/bin/composer