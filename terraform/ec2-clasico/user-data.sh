#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -e

yum update -y

amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx

amazon-linux-extras install php8.2 -y

yum install -y \
php \
php-cli \
php-fpm \
php-mysqlnd \
php-json \
php-mbstring \
php-xml \
php-intl \
php-zip \
php-opcache \
git \
unzip

systemctl enable php-fpm
systemctl start php-fpm

export NVM_DIR="/root/.nvm"
mkdir -p $NVM_DIR

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | NVM_DIR=$NVM_DIR bash


source /root/.nvm/nvm.sh

nvm install 16
nvm use 16

node -v
npm -v

cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer

composer -V

yum install -y mariadb-server
systemctl enable mariadb
systemctl start mariadb

until mysqladmin ping --silent; do
sleep 2
done

mysql -e "CREATE DATABASE IF NOT EXISTS symfony_db;"

cd /home/ec2-user
git clone https://github.com/Alejandro-Polo/pruebadespliegue.git
chown -R ec2-user:ec2-user pruebasdespliegue

cd /home/ec2-user/pruebadespliegue/backend

sed -i 's|DATABASE_URL=.*|DATABASE_URL="mysql://root@127.0.0.1:3306/symfony_db"|g' .env

composer install --no-interaction --no-progress

php bin/console doctrine:migrations:migrate --no-interaction || true

chmod o+x /home/ec2-user
chmod -R 755 /home/ec2-user/pruebadespliegue
chown -R nginx:nginx /home/ec2-user/pruebadespliegue/backend/var || true

cd /home/ec2-user/pruebadespliegue/frontend

npm install
npm run build

rm -rf /usr/share/nginx/html/*
cp -r dist/* /usr/share/nginx/html/

cat > /etc/nginx/conf.d/app.conf <<'EOF'
server {

    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    # React
    location / {
        try_files $uri /index.html;
    }

    # Symfony API
    location /api {
        root /home/ec2-user/pruebadespliegue/backend/public;
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php(/|$) {

        root /home/ec2-user/pruebadespliegue/backend/public;

        fastcgi_pass unix:/run/php-fpm/www.sock;
        include fastcgi_params;

        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;

        internal;
    }
}
EOF

systemctl restart nginx