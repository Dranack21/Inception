#!/bin/sh
set -e

echo "=== MariaDB Initialization Script Started ==="

mkdir -p /var/lib/mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start temporary server
    mysqld --user=mysql --datadir=/var/lib/mysql &
    
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done
    
    mysql -uroot <<EOF
        SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MARIADB_ROOT_PASSWORD}');
        CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
        FLUSH PRIVILEGES;
EOF
    mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
else
    echo "Existing database found"
    
    # Start temporary server
    mysqld --user=mysql --datadir=/var/lib/mysql &
    
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done
    
    # CRITICAL FIX: Always ensure user permissions
    mysql -u root -p"${MARIADB_ROOT_PASSWORD}" <<EOF
        CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
        FLUSH PRIVILEGES;
EOF
    mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
fi

echo "Starting MariaDB server..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0