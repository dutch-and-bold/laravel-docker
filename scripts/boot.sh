#!/bin/bash

# Store env for cron

printenv | sed -r "s/'/\\\'/gm" | sed -r "s/^([^=]+=)(.*)\$/\1'\2'/gm" > /etc/environment
chown www-data:www-data /etc/environment

# Remove xdebug when it's not needed

if [ "$XDEBUG_REMOTE_ENABLE" == 0 ]; then
    rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    echo "$(date) [laravel-docker] Removed xdebug config"
fi

# Set NGINX conf env variables

## Create a self signed SSL for test configurations

if [ ! -f /config/ssl/fullchain.pem ]; then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /config/ssl/privkey.pem -out /config/ssl/fullchain.pem \
    -subj '/C=US/ST=TEST/L=TEST/O=TEST/CN=localhost'

    echo "$(date) [laravel-docker] Self signed SSL certificate was successfully created"
fi

## Set env vars in nginx config

envsubst '${NGINX_GZIP_ENABLED} ${NGINX_ASSETS_EXPIRE_IN} ${NGINX_SERVER_NAME} ${NGINX_LISTEN} ${NGINX_SSL} ${NGINX_SSL_CERTIFICATE} ${NGINX_SSL_CERTIFICATE_KEY} ${NGINX_SSL_PROTOCOLS} ${NGINX_SSL_CIPHERS} ${PHP_UPLOAD_MAX_FILESIZE}' \
          < /config/nginx-default.conf > /etc/nginx/sites-available/default

echo "$(date) [laravel-docker] Set ENV vars on the default nginx config"

# Run deploy script

runuser -u www-data "/scripts/deployed.sh"
echo "$(date) [laravel-docker] Ran /scripts/deployed.sh"

# Create certificates

if [ "$LETSENCRYPT_DOMAINS" ]; then
    DOMAIN=$(echo $LETSENCRYPT_DOMAINS | sed -r "s/(^.*?)\-d.*$/\1/")

    if [ ! -d "$CERT_HOME/$DOMAIN" ]; then
        service nginx start
        /acme.sh/acme.sh --issue -d $LETSENCRYPT_DOMAINS -w /web/public
        service nginx stop
    fi

    /acme.sh/acme.sh --install-cert -d $DOMAIN \
            --key-file       "$LETSENCRYPT_SSL_PATH/privkey.pem"   \
            --fullchain-file "$LETSENCRYPT_SSL_PATH/fullchain.pem" \
            --reloadcmd      "service nginx force-reload"
fi

# Run supervisor

exec supervisord -n -c /config/supervisord.conf