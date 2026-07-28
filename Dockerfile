# Dockerfile — NYX PHP Relay Server (Railway-Ready)
FROM php:8.1-apache

# 1. Install system dependencies for PostgreSQL AND SQLite
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libsqlite3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Install PHP extensions (PDO, PostgreSQL, SQLite)
RUN docker-php-ext-install pdo pdo_pgsql pdo_sqlite

# 3. Fix Apache MPM conflict (CRITICAL for php:8.1-apache on Debian Bookworm)
RUN a2dismod mpm_event || true
RUN a2dismod mpm_worker || true
RUN a2enmod mpm_prefork
RUN a2enmod rewrite

# 4. Set the document root to the server directory
ENV APACHE_DOCUMENT_ROOT=/var/www/html/server

# 5. Update Apache configuration to use the new document root
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 6. Copy server files from the server/ directory
COPY server/ /var/www/html/server/

# 7. Set correct permissions for Apache
RUN chown -R www-data:www-data /var/www/html

# 8. Environment variables for dual-database support
ENV DRIVER=sqlite
ENV DATABASE_URL=""

# 9. Expose port 80 (Railway automatically routes traffic to this)
EXPOSE 80

# 10. Start Apache
CMD ["apache2-foreground"]
