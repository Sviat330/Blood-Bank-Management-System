#!/bin/sh
export DOLLAR="$"
export PHP_FPM_PORT="9000"
# Retrieve IP address of the PHP-FPM container
x=1
while [ $x -lt 10 ] 
do
PHP_FPM_IP=$(curl  ${ECS_CONTAINER_METADATA_URI_V4}/task | jq -r '.Containers[1].Networks[].IPv4Addresses[0]')
OWN_IP=$(hostname -i)
if [ "$OWN_IP" == "$PHP_FPM_IP" ]
then
PHP_FPM_IP=$(curl  ${ECS_CONTAINER_METADATA_URI_V4}/task | jq -r '.Containers[0].Networks[].IPv4Addresses[0]')
fi
x=`expr $x + 1`
if [ -z ${PHP_FPM_IP} ]
then
	continue
else
	break
fi
done
# Set environment variable
if [ -z ${PHP_FPM_IP} ]
then
	PHP_FPM_IP="fpm"
fi
export PHP_FPM_HOST=$PHP_FPM_IP
echo $PHP_FPM_HOST
# Start Nginx

envsubst < /root/bloodbank_docker >/etc/nginx/conf.d/default.conf
nginx -g "daemon off;"
