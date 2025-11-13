ARG PHP_VERSION=8.2

FROM php:${PHP_VERSION}-apache

ARG WORDPRESS_DB_NAME=root_database
ARG WORDPRESS_DB_USER=random_user
ARG WORDPRESS_DB_PASSWORD=TH3p455w0rd
ARG WORDPRESS_DB_HOST=mysql
ARG MODE_URL=http://localhost:3000

ENV WORDPRESS_DB_NAME = ${MYSQL_DATABASE} \
    WORDPRESS_DB_USER = ${MYSQL_USER} \
    WORDPRESS_DB_PASSWORD = ${MYSQL_PASSWORD} \
    WORDPRESS_DB_HOST = ${WORDPRESS_DB_HOST} \
    MODE_URL = ${MODE_URL}

RUN docker-php-ext-install mysqli 

###para php viejo, se debe buscar en librerías legacy de SSL
#RUN sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g' /etc/apt/sources.list \
#        && sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list \
#        && echo "Acquire::Check-Valid-Until false;" > /etc/apt/apt.conf.d/99no-check-valid \
#        && apt-get update \
#        && apt-get install -y --no-install-recommends \
#             ca-certificates curl unzip \
#        && update-ca-certificates \
#        && rm -rf /var/lib/apt/lists/*

##comentar esto si se activa lo de arriba
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
             ca-certificates curl unzip \
        && update-ca-certificates \
        && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite
COPY ./configs/php/php.ini /usr/local/etc/php/
WORKDIR /var/www/html