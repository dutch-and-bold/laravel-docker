#!/bin/bash

if [ -f artisan ]; then
    php artisan migrate
fi