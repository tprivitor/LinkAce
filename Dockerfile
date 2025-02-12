FROM php:8.1-fpm

WORKDIR /var/www

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql mbstring exif pcntl bcmath opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . .

# Ensure correct permissions
RUN chown -R www-data:www-data /var/www

# Prevent memory limit issues
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory-limit.ini

# Install dependencies safely
RUN composer install --no-dev --optimize-autoloader --no-interaction || true

# Generate Laravel application key
RUN php artisan key:generate || true

# Start the application
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

EXPOSE 8000
