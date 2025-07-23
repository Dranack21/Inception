FROM debian:bullseye

RUN apt update && apt install -y nginx && apt install -y openssl

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/CN=habouda42"



##DOCUMENTATION DOESNT DO ANYTHING
EXPOSE 80

##CAN ONLY BE ONE LAST ONE WINS
#Important cause in docker nginx needs to be in the foregreound else docker exits
COPY /default.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]