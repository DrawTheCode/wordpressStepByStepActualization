ARG PHP_VERSION=7.2.34
FROM php:${PHP_VERSION}-apache
RUN docker-php-ext-install mysqli 
RUN a2enmod rewrite
COPY ./configs/php/php.ini /usr/local/etc/php/
WORKDIR /var/www/html