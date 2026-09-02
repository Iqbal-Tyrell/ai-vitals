#!/bin/sh
set -e

# On first boot (or first boot after a volume reset), seed .env from the
# committed example and persist it in the storage volume so APP_KEY
# survives image rebuilds. Both the app and scheduler containers share
# this file via the same volume.
if [ ! -f storage/.env ]; then
    cp .env.example storage/.env
fi
ln -sf storage/.env .env

if ! grep -q '^APP_KEY=base64' .env; then
    php artisan key:generate --force --no-interaction
fi

if [ "$RUN_MIGRATIONS" = "true" ]; then
    php artisan migrate --force
fi

exec "$@"
