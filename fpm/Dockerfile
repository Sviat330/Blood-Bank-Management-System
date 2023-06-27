FROM php:8.1.19-fpm-alpine3.18
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli && apk add  phpunit
COPY web /var/www/html
COPY ./ /tmp
RUN cd /tmp && phpunit web/test/indextest.php
WORKDIR /tmp
