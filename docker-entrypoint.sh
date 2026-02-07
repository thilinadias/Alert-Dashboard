#!/bin/sh

# Exit on error
set -e

# Wait for database
echo "Waiting for database ($DB_HOST:3306)..."
while ! nc -z $DB_HOST 3306; do
  sleep 2
done
echo "Database is ready!"

# Install dependencies if vendor is missing
if [ ! -d "vendor" ]; then
    composer install --no-interaction --optimize-autoloader --no-dev
fi

# Ensure .env exists
if [ ! -f ".env" ]; then
    cp .env.example .env
    php artisan key:generate
fi

# Run migrations
php artisan migrate --force

# Link storage
php artisan storage:link

# Start PHP-FPM
exec php-fpm
