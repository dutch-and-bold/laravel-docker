# Laravel-Docker

This image provides an plug-and-play environment for your Laravel application to run.
The image can be used for production in a Dockerfile, but also can be ran with docker run or docker-compose for 
your development environments.

# Table of contents

- [Laravel-Docker](#laravel-docker)
  * [Maintainers](#maintainers)
  * [Docker](#docker)
    + [Dockerfile](#dockerfile)
    + [Docker-compose](#docker-compose)
  * [Laravel](#laravel)
    + [Queue Worker](#queue-worker)
    + [Scheduler](#scheduler)
  * [PHP](#php)
    + [Configuration](#configuration)
  * [Xdebug](#xdebug)
  * [NGINX](#nginx)
    + [Configuration](#configuration-1)
  * [Deploy script](#deploy-script)
    + [Custom script](#custom-script)
  * [Locales](#locales)

## Maintainers

This docker image is maintained by two enthusiastic dutch companies.
- [Dutch & Bold](https://www.dutchandbold.com) - Rotterdam, the Netherlands
- [Webbits](https://www.webbits.nl) - Rijswijk, the Netherlands

## Docker

Using docker run is a nice basic method to get your files up and running quickly.

```bash
docker run \
    --name=example \
    -v ./:/web \
    -p 80:80 \
    dutchandbold/laravel-docker
```

### Dockerfile

For production this is the preferred method. Use this image in your docker file and COPY your project's files into 
the container.

For example:

```dockerfile
FROM dutchandbold/laravel-docker

ENV APP_ENV production

COPY --chown=www-data . /web

RUN su - www-data -s /bin/bash -c "composer install --no-dev --optimize-autoloader --no-interaction -d /web"
```

### Docker-compose

For development this might be the best method to run your project. You can use this image and mount your files into it.

For example:
```yaml
version: '3.3'
services:
  app:
    image: dutchandbold/laravel-docker:latest
    ports:
      - '80:80'
    restart: always
    volumes:
      - ./:/web
    environment:
      DB_HOST: db
    links:
      - db
    depends_on:
      - db

  db:
    image: mysql
    restart: always
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
    environment:
      MYSQL_DATABASE: 'homestead'
      MYSQL_USER: 'homestead'
      MYSQL_PASSWORD: 'secret'
      MYSQL_ROOT_PASSWORD: 'secret'
volumes:
  mysql-data:
```

## Laravel

This package is made to work for Laravel out of the box. It supports features such as a supervised queue or
the scheduler out of the box.

### Queue Worker

By default the queue worker is not enabled. But not to worry. We have made it really easy to enable.
To enable the queue worker you only have to set an environment variable.

|Environment variable|Default value|Description                |
|--------------------|-------------|---------------------------|
|`WORKER_NUMPROCS`   |0            |Number of workers          |
|`WORKER_SLEEP`      |3            |Sleep between jobs         |
|`WORKER_TRIES`      |3            |Max attempts if a job fails|
|`WORKER_TIMEOUT`    |60           |Timeout for frozen jobs    |
|`QUEUE_DRIVER`      |             |Same as Laravel            |

More info at [Laravel docs | Queues](https://laravel.com/docs/5.6/queues)

### Scheduler

The laravel scheduler runs by default if artisan exists in the `/web` folder

## PHP

This image is based on the official PHP image PHP7.2-fpm.

### Configuration

One option to configure php is to overwrite the php.ini like so:

```dockerfile
COPY php.ini /usr/local/etc/php/
```

But we have also made some options available through environment variables.

|Environment variable     |Default value|Description                |
|-------------------------|-------------|---------------------------|
|`PHP_MEMORY_LIMIT`       |128M         |memory_limit               |
|`PHP_POST_MAX_SIZE`      |8M           |post_max_size              |
|`PHP_UPLOAD_MAX_FILESIZE`|2M           |upload_max_filesize        |


## Xdebug

This functionality is built in. But if not enabled. It won't be loaded.
Xdebug can be setup by environment variables

|Environment variable           |Default value                      |Description                |
|-------------------------------|-----------------------------------|---------------------------|
|`XDEBUG_REMOTE_ENABLE`         |0                                  |This enables xdebug        |
|`XDEBUG_REMOTE_AUTOSTART`      |0                                  |Autostart                  |
|`XDEBUG_REMOTE_PORT`           |9000                               |Remote port                |
|`XDEBUG_REMOTE_HOST`           |localhost                          |Remote host                |
|`XDEBUG_PROFILER_ENABLE`       |0                                  |This enables the profiler  |
|`XDEBUG_PROFILER_OUTPUT_DIR`   |/web/storage/logs/xdebug/profiler  |Change the default dir     |
|`PHP_UPLOAD_MAX_FILESIZE`      |2M                                 |Sets client_max_body_size  |

## NGINX

### Configuration

The default configuration probably suits most use cases. But you can always supply your own. Just copy it to:
```
/etc/nginx/sites-available/
```
or overwrite the default
```dockerfile
COPY nginx.conf /etc/nginx/sites-available/default
```

When using the default, there are some configuration options. These will only be applied at boot.

|Environment variable           |Default value                      |Description                |
|-------------------------------|-----------------------------------|---------------------------|
|`NGINX_GZIP_ENABLED`           |on                                 |Switches GZIP              |
|`NGINX_ASSETS_EXPIRE_IN`       |14d                                |Set an expiry on assets    |
|`NGINX_SERVER_NAME`            |_                                  |Server name                |
|`NGINX_LISTEN`                 |80 default_server                  |Listening on this port     |
|`NGINX_SSL`                    |off;                               |Turn SSL on/off            |
|`NGINX_SSL_CERTIFICATE`        |/config/ssl/fullchain.pem;         |SSL Certificate            |
|`NGINX_SSL_CERTIFICATE_KEY`    |/config/ssl/privkey.pem;           |SSL Key                    |
|`NGINX_SSL_PROTOCOLS`          |TLSv1 TLSv1.1 TLSv1.2;             |SSL Protocols              |
|`NGINX_SSL_CIPHERS`            |HIGH:!aNULL:!MD5;                  |SSL Ciphers                |

For more information reference the nginx documentation located at [http://nginx.org/en/docs/](http://nginx.org/en/docs/)

## Deploy script

By default the deploy script just runs the migrations if artisan is available. 

### Custom script

You can overwrite this script, for example:

```dockerfile
COPY script.sh /scripts/deployed.sh
```

The working dir for this script is `/web` and the user is `www-data`

## Locales

This image comes preinstalled with the en_US locales. To add extra locales we have added a simple command to do so.
You can call `add-locale` with the installable locales as arguments at any point. But preferably in your Dockerfile.

For example:
```dockerfile
RUN add-locale nl_NL es_ES it_IT
```