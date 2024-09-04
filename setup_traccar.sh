#!/bin/bash

set -e

source .env

git pull origin main

mkdir -p ~/traccar/backend ~/traccar/webapp ~/traccar/certs ~/traccar/nginx

cp backend/Dockerfile.backend ~/traccar/backend/Dockerfile
cp webapp/Dockerfile.webapp ~/traccar/webapp/Dockerfile
cp nginx/nginx.conf ~/traccar/nginx/nginx.conf

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/traccar/certs/selfsigned.key -out ~/traccar/certs/selfsigned.crt -subj "/CN=${EC2_PUBLIC_IP}"

sed -i "s/\${EC2_PUBLIC_IP}/${EC2_PUBLIC_IP}/g" ~/traccar/nginx/nginx.conf

cp ~/traccar/backend/setup/traccar.xml ~/traccar/backend/conf/traccar.xml

docker-compose up -d --build

echo "Setup complete! Access your Traccar application at https://${EC2_PUBLIC_IP} or your server's IP."