#!/bin/bash

if [ -f /web/artisan ]; then
    /usr/local/bin/php /web/artisan schedule:run
fi