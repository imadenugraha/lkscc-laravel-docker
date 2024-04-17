#
# Backend
#
FROM composer:2.7.2 AS VENDOR

WORKDIR /app

COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --prefer-dist \
    --ignore-platform-reqs \
    --no-interaction \
    --no-scripts

#
# Frontend
#
FROM node:18.20.1-alpine AS FRONTEND

WORKDIR /app

COPY package.json package.json
COPY vite.config.js vite.config.js
COPY resources/js resources/js
COPY resources/css resources/css

RUN npm install && \
    npm run build

#
# Apache
#
FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    zip \
    unzip && \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd pdo mbstring pdo_mysql

WORKDIR /var/www/html/laravel-app

COPY . .
COPY laravel.conf /etc/apache2/sites-available/laravel.conf
COPY --from=VENDOR /app/vendor/ /var/www/html/laravel-app/vendor
COPY --from=FRONTEND /app/public/build/ /var/www/html/laravel-app/public/build/

RUN chown -R www-data bootstrap/cache public storage

RUN a2enmod rewrite && \
    a2dissite 000-default.conf && \
    a2ensite laravel.conf

EXPOSE 80

CMD ["apache2ctl", "-DFOREGROUND"]
