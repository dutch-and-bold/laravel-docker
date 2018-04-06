# Laravel-Docker

This image provides an plug-and-play environment for your Laravel application to run.
The image can be used for production in a Dockerfile, but also can be ran with docker run or docker-compose for 
your development environments.

## Maintainers

This docker image is maintained by two enthusiastic dutch companies.
- [Dutch & Bold](https://www.dutchandbold.com) - Rotterdam, the Netherlands
- [Webbits](https://www.webbits.nl) - Rijswijk, the Netherlands

## Dockerfile

For production this is the prefered method. Use this image in your docker file and COPY your project's files into 
the container.

For example:

```dockerfile
FROM dutchandbold/laravel-docker:latest

ENV WORKER_NUMPROCS 1

COPY . /web
RUN composer install -d /web
```

## Docker-compose

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

## Docker

Using docker is also a nice basic method to get your files up and running quickly.

```bash
docker run \
    --name=example \
    -v ./:/web \
    -p 80:80 \
    dutchandbold/laravel-docker
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

More info at [Laravel docs | Queues](https://laravel.com/docs/5.6/queues)

### Scheduler

The laravel scheduler runs by default if artisan exists in the `/web` folder