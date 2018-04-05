FROM php:7.2-fpm

ENV WORKER_SLEEP 3
ENV WORKER_TRIES 3
ENV WORKER_TIMEOUT 60
ENV WORKER_NUMPROCS 0
ENV NGINX_VERSION 1.10.3-1+deb9u1

LABEL maintainer="Dylan Lamers <dylan@dutchandbold.com>"

# Update package repositories

RUN apt-get update

# install nginx

RUN apt-get install -y nginx=$NGINX_VERSION

# Install supervisord

RUN apt-get install -y supervisor

# Setup php with extensions

RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libicu-dev \
        libxslt-dev \
        cron

RUN docker-php-ext-install -j$(nproc) gd exif intl xsl json soap dom zip opcache
RUN pecl install mcrypt-1.0.1
RUN docker-php-ext-enable mcrypt

# Install composer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \

# Forward request and error logs to docker log collector

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# Copy the default index.php into /web

COPY index.php /web/public/index.php

# Make /web owned by www-data

RUN chown www-data:www-data /web

# Setup supervisord config

COPY config/supervisord.conf /config/supervisord.conf

# Setup PHP FPM config

COPY config/php-fpm.conf /config/php-fpm.conf

# Copy default nginx config

COPY config/nginx-default.conf /etc/nginx/sites-available/default

# Laravel Scheduler

COPY laravel-cron.sh /laravel-cron.sh
RUN chown www-data:www-data /laravel-cron.sh \
    && chmod a+x /laravel-cron.sh
RUN echo '* * * * * /laraval-cron.sh >> /dev/null 2>&1' >> /tmp/crontab.tmp \
    && crontab -u www-data /tmp/crontab.tmp \
    && rm -rf /tmp/crontab.tmp

# Expose http and https ports

EXPOSE 443 80

# Run supervisor

CMD ["supervisord", "-n", "-c", "/config/supervisord.conf"]