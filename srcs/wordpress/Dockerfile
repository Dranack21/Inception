FROM debian:bullseye

RUN apt update && apt install -y \
    php-fpm \
    php-mysql \
    wget \
    tar \
    curl \
    mariadb-client \
    unzip

# Create necessary directories
RUN mkdir -p /var/www/html \
    && mkdir -p /run/php

# Download and install WordPress
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress/* /var/www/html && \
    rm -rf wordpress latest.tar.gz

# Configure PHP-FPM
RUN sed -i 's|listen = .*|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf

# Set proper ownership and permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["php-fpm7.4", "-F"]