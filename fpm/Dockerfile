FROM php:8.1.19-fpm-alpine3.18
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli 
COPY web /var/www/html
