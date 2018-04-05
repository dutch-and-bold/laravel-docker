#!/bin/bash

if [ -f /web/artisan ]; then
    php /web/artisan schedule:run
fi