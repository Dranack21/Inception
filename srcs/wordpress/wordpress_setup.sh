#!/bin/bash

echo "=== WordPress Setup Script Started ==="

# Debug: Print environment variables
echo "WORDPRESS_DB_NAME: $WORDPRESS_DB_NAME"
echo "WORDPRESS_DB_USER: $WORDPRESS_DB_USER"
echo "WORDPRESS_DB_HOST: $WORDPRESS_DB_HOST"
echo "WORDPRESS_DB_PASSWORD: $WORDPRESS_DB_PASSWORD"
echo "WORDPRESS_USER_NAME: $WORDPRESS_USER_NAME"
echo "WORDPRESS_USER_EMAIL: $WORDPRESS_USER_EMAIL"
echo "WORDPRESS_USER_ROLE: $WORDPRESS_USER_ROLE"
echo "WORDPRESS_USER_PASSWORD: $WORDPRESS_USER_PASSWORD"
echo "WORDPRESS_ADMIN_USER: $WORDPRESS_ADMIN_USER"
echo "WORDPRESS_ADMIN_PASSWORD: $WORDPRESS_ADMIN_PASSWORD"
echo "WORDPRESS_ADMIN_EMAIL: $WORDPRESS_ADMIN_EMAIL"
echo "WORDPRESS_URL: $WORDPRESS_URL"
echo "WORDPRESS_TITLE: $WORDPRESS_TITLE"
echo "=================================="

if [ -f ./wp-config.php ]; then
    echo "WordPress configuration file already exists. Skipping setup."
else
    echo "Waiting for database to be ready..."
    
    # Wait for database connection
    while ! mysqladmin ping -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
        echo "Waiting for database connection... (Host: $WORDPRESS_DB_HOST, User: $WORDPRESS_DB_USER)"
        sleep 2
    done

    echo "Database is ready! Creating wp-config..."
    wp config create \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$WORDPRESS_DB_PASSWORD \
        --dbhost=$WORDPRESS_DB_HOST \
        --allow-root

    echo "Installing WordPress core..."
    wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root

    echo "Creating additional WordPress user..."
    wp user create $WORDPRESS_USER_NAME $WORDPRESS_USER_EMAIL \
        --role=$WORDPRESS_USER_ROLE \
        --user_pass=$WORDPRESS_USER_PASSWORD \
        --allow-root
fi

echo "Starting php-fpm..."
exec php-fpm7.4 -F