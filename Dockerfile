# Using php:8.2-apache as base
FROM php:8.2-apache

# Add NodeJS repository
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

# Install dependency for Laravel and install NodeJS
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install php-extension for Laravel using docker-php-ext-install
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Change working directory
WORKDIR /var/www/html/laravel

# Copy all to working directory
COPY . .

# Build application and running migration
RUN npm install && \
    npm run build && \
    composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist && \
    php artisan migrate

# Change owner of folder bootstrap/cache, public, and storage to www-data
RUN chown -R www-data:www-data bootstrap/cache public storage

# Enable Apache Rewrite module
RUN a2enmod rewrite

# Copy apache2 configuration
COPY laravel.conf /etc/apache2/sites-available/laravel.conf

# Disable default configuration and enable the new one
RUN a2dissite 000-default.conf && \
    a2ensite laravel.conf

# Open port for apache2
EXPOSE 80

# Disable apache2 run in background
CMD [ "apache2ctl", "-DFOREGROUND" ]
