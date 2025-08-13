#!/bin/sh
set -e

echo "=== MariaDB Initialization Script Started ==="

mkdir -p /var/lib/mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    mysqld --user=mysql --datadir=/var/lib/mysql &
    
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done
    
    mysql -uroot <<EOF
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE user = '';
        CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'localhost' IDENTIFIED BY '${MARIADB_PASSWORD}';
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'localhost';
        GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
        FLUSH PRIVILEGES;
EOF
    mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
else
    echo "Existing database found"
    
    mysqld --user=mysql --datadir=/var/lib/mysql &
    
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done
    
    mysql -u root -p"${MARIADB_ROOT_PASSWORD}" <<EOF
        CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'localhost' IDENTIFIED BY '${MARIADB_PASSWORD}';
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
        ALTER USER '${MARIADB_USER}'@'localhost' IDENTIFIED BY '${MARIADB_PASSWORD}';
        ALTER USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'localhost';
        GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
        FLUSH PRIVILEGES;
EOF
    mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
fi

echo "Starting MariaDB server..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0