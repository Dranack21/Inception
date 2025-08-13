FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    curl \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-json \
    php7.4-curl \
    php7.4-dom \
    php7.4-exif \
    php7.4-fileinfo \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

#WORDPRESS COMMAND LINE INTERFACE INSTALALTION
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp


RUN mkdir -p /run/php
COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf

#WORDPRESS ITSELF
RUN mkdir -p /var/www/html \
    && curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 \
    && rm /tmp/wordpress.tar.gz

#COPY SCRIPT INTO CONTAINER
COPY wordpress_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress_setup.sh

RUN chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/wordpress_setup.sh"]
CMD ["php-fpm7.4", "-F"]