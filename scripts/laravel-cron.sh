#!/bin/bash

cd /web

if [ -f artisan ]; then
    /usr/local/bin/php artisan schedule:run
fi