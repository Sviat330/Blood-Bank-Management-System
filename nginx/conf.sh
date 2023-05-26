#!/bin/sh
export DOLLAR="$"
export PHP_FPM_PORT="9000"
# Retrieve IP address of the PHP-FPM container
PHP_FPM_IP=$(curl  ${ECS_CONTAINER_METADATA_URI_V4}/task | jq -r '.Containers[-1].Networks[].IPv4Addresses[0]')

# Set environment variable
export PHP_FPM_HOST=$PHP_FPM_IP

# Start Nginx
envsubst < /root/bloodbank_docker >/etc/nginx/conf.d/default.conf
nginx -g "daemon off;"

