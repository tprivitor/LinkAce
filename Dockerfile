FROM php:8.1-fpm

WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mbstring exif pcntl bcmath opcache

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . .

# Ensure proper permissions
RUN chown -R www-data:www-data /var/www

# Fix potential issues with Composer
RUN composer clear-cache && composer update --no-interaction --prefer-dist

# Install dependencies properly
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction

# Generate Laravel application key
RUN php artisan key:generate

# Start the application
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

EXPOSE 8000
