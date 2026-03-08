#!/bin/bash
exec > /var/log/user-data.log 2>&1

yum update -y

amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx

amazon-linux-extras enable php8.1
yum clean metadata
yum install -y php php-cli php-fpm php-mysqlnd php-json php-mbstring php-xml git unzip

systemctl enable php-fpm
systemctl start php-fpm

amazon-linux-extras install nodejs18 -y

cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php
php composer-setup.php --install-dir=/usr/local/bin --filename=composer

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

chmod o+x /home/ec2-user
chmod -R 755 /home/ec2-user/pruebadespliegue
chown -R nginx:nginx /home/ec2-user/pruebadespliegue/backend/var

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

    location / {
        try_files $uri /index.html;
    }

    location /api {
        root /home/ec2-user/pruebadespliegue/backend/public;
        try_files $uri /index.php$is_args$args;
    }

    location /articulo {
        root /home/ec2-user/pruebadespliegue/backend/public;
        try_files $uri /index.php$is_args$args;
    }

    location ~ ^/index\.php(/|$) {

        root /home/ec2-user/pruebadespliegue/backend/public;
        fastcgi_pass unix:/run/php-fpm/www.sock;

        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;

    }
}
EOF

systemctl restart nginx