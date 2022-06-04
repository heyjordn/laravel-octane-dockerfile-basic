#!/usr/bin/env bash
set -e

php() {
  su octane -c "php $*"
}

# Prepare caching etc.

php artisan optimize:clear; \
php artisan package:discover --ansi; \
php artisan event:cache; \
php artisan config:cache; \
php artisan route:cache;

# Starts supervisord
# We still use supervisor here in case we need to easily add 
# horizon process to the start up, which is kinda common
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.app.conf

