#!/bin/bash
set -e


# wait for DB to be ready (simple loop)
if [ -n "$DB_HOST" ]; then
echo "Waiting for database ($DB_HOST:$DB_PORT) to be ready..."
until mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e 'SELECT 1' >/dev/null 2>&1; do
sleep 1
done
fi


# run pending migrations and prepare the app
bundle exec rails db:create db:migrate 2>/dev/null || true
bundle exec rails db:migrate


# Precompile assets in production if requested
if [ "$RAILS_ENV" = "production" ]; then
bundle exec rails assets:precompile
fi


exec "$@"