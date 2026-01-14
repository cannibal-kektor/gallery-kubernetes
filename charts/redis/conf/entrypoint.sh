#!/bin/sh
set -e

CONF_DIR="/usr/local/etc/redis"
TEMPLATE_DIR="/app/redis"
mkdir -p "$CONF_DIR"

sed -e "s/REDIS_USER/$REDIS_USER/g" -e "s/REDIS_PASSWORD/$REDIS_PASSWORD/g" \
    "$TEMPLATE_DIR/users.template.acl" > "$CONF_DIR/users.acl"

sed -e "s/REDIS_DEFAULT_PASSWORD/$REDIS_DEFAULT_PASSWORD/g" \
    "$TEMPLATE_DIR/redis.template.conf" > "$CONF_DIR/redis.conf"

exec docker-entrypoint.sh redis-server "$CONF_DIR/redis.conf" --aclfile "$CONF_DIR/users.acl"