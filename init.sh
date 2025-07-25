#!/bin/bash

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
while ! mysqladmin ping -h mysql -u root -p${DB_ROOT_PASSWORD} --silent; do
    sleep 1
done

# Generate application key if not exists
if [ -z "$APP_KEY" ]; then
    echo "Generating application key..."
    APP_KEY=$(php artisan key:generate --show)
    export APP_KEY
fi

# Run Laravel commands
echo "Running Laravel setup..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations
echo "Running database migrations..."
php artisan migrate --force

# Seed database (optional)
# php artisan db:seed --force

# Set permissions
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Start supervisord
echo "Starting services..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
