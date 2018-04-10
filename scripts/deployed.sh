#!/bin/bash

echo "$(date) [deployed.sh] Running deploy script"

if [ -f artisan ]; then
    php artisan migrate
fi