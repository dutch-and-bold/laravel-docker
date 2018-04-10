#!/bin/bash

# Remove xdebug when it's not needed

if [ "$XDEBUG_REMOTE_ENABLE" == 0 ]; then
    rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    echo "$(date) [laravel-docker] Removed xdebug config"
fi

# Run deploy script

su - www-data -c "/scripts/deployed.sh" -s /bin/bash
echo "$(date) [laravel-docker] Ran /scripts/deployed.sh"

# Run supervisor

exec supervisord -n -c /config/supervisord.conf