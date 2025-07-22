FROM debian:bullseye
RUN apt-get update && apt-get install -y mariadb-server
COPY script.sh /usr/local/bin/script.sh 
RUN chmod +x /usr/local/bin/script.sh
RUN mkdir /run/mysqld


EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/script.sh"]