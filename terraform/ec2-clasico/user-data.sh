#!/bin/bash

exec > /var/log/user-data.log 2>&1

yum update -y

amazon-linux-extras install -y nginx1
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

sed -i 's|DATABASE_URL=.*|DATABASE_URL="mysql://root:@127.0.0.1:3306/symfony_db"|g' .env

composer install --no-interaction

php bin/console doctrine:migrations:migrate --no-interaction || true

chown -R nginx:nginx /home/ec2-user/pruebadespliegue/backend
chmod -R 755 /home/ec2-user/pruebadespliegue/backend
chmod -R 775 /home/ec2-user/pruebadespliegue/backend/var

cd ../frontend

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

    # API Symfony
    location /api {
        alias /home/ec2-user/pruebadespliegue/backend/public;
        try_files $uri /index.php$is_args$args;
    }

    # CRUD Symfony
    location /articulo {
        alias /home/ec2-user/pruebadespliegue/backend/public;
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php(/|$) {
        root /home/ec2-user/pruebadespliegue/backend/public;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root/index.php;
    }
}
EOF

systemctl restart nginx