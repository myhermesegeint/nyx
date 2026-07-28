FROM php:8.2-apache

# 1. Install system dependencies for PostgreSQL AND SQLite
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libsqlite3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Install PHP extensions (PDO, PostgreSQL, SQLite)
RUN docker-php-ext-install pdo pdo_pgsql pdo_sqlite

# 3. Set working directory and copy files
WORKDIR /var/www/html
COPY . /var/www/html/

# 4. Set correct permissions for Apache
RUN chown -R www-data:www-data /var/www/html

# 5. Expose port 80 (Railway automatically routes traffic to this)
EXPOSE 80

CMD ["apache2-foreground"]
