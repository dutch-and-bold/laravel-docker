FROM php:7.2-fpm

ENV WORKER_SLEEP 3
ENV WORKER_TRIES 3
ENV WORKER_TIMEOUT 60
ENV WORKER_NUMPROCS 0
ENV NGINX_VERSION 1.10.3-1+deb9u1

LABEL maintainer="Dylan Lamers <dylan@dutchandbold.com>"

RUN apt-get update

RUN apt-get install -y \
        nginx=$NGINX_VERSION \
        supervisor \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libicu-dev \
        libxslt-dev

RUN docker-php-ext-install -j$(nproc) gd exif intl xsl json soap dom zip opcache
RUN pecl install mcrypt-1.0.1
RUN docker-php-ext-enable mcrypt

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN service nginx start

RUN mkdir /home/nginx \
    && mkdir /conf \
    && mkdir /web

COPY index.php /web/index.php

RUN chown www-data:www-data /web

COPY config/supervisord.conf /config/supervisord.conf
COPY config/php-fpm.conf /config/php-fpm.conf

COPY config/nginx-default.conf /etc/nginx/sites-available/default

EXPOSE 443 80

CMD ["supervisord", "-n", "-c", "/config/supervisord.conf"]