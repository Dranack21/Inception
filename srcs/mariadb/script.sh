#!/bin/sh
set -e

# Create necessary directories
mkdir -p /var/lib/mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    echo "Starting MariaDB in background for initialization..."
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    
    # Wait for MySQL to start
    until mysqladmin ping --silent; do
        sleep 1
    done
    
    echo "Setting up MariaDB root password and database..."
    mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD';"
    mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\`;"
    
    # Create user with access from any host
    mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e \
      "CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';"
    
    mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e \
      "GRANT ALL PRIVILEGES ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'%';"
    
    echo "Removing anonymous users..."
    mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e "DELETE FROM mysql.user WHERE User = '';"
    
    mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
    
    echo "Database setup completed successfully."
    echo "Shutting down MariaDB background server..."
    mysqladmin -uroot -p"$MARIADB_ROOT_PASSWORD" shutdown
else
    echo "MariaDB data directory already exists, skipping initialization..."
fi

echo "Starting MariaDB server..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0