#!/bin/sh
set -e

# Créer les répertoires nécessaires
mkdir -p /var/lib/mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Initialisation de la base de données si elle n'existe pas encore
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation du répertoire MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    echo "Démarrage temporaire de MariaDB pour configuration initiale..."
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    
    # Attendre que MariaDB soit prêt
    until mysqladmin ping --silent; do
        sleep 1
    done

    echo "Configuration de MariaDB root et base de données..."

    # Définir le mot de passe root
    mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"

    # Créer la base de données
    mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"

    # Supprimer l'utilisateur existant s'il y a conflit
    mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "DROP USER IF EXISTS '${MARIADB_USER}'@'%';"

    # Créer l'utilisateur avec accès depuis n'importe où
    mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"

    # Donner les droits à l'utilisateur sur la base
    mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';"

    # Nettoyage
    mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "DELETE FROM mysql.user WHERE User = '';"
    mysql -uroot -p"${MARIADB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

    echo "Configuration terminée. Arrêt du serveur MariaDB temporaire..."
    mysqladmin -uroot -p"${MARIADB_ROOT_PASSWORD}" shutdown
else
    echo "Répertoire MariaDB déjà initialisé, on passe."
fi

echo "Démarrage final du serveur MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
