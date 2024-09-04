#!/bin/bash

set -e

source .env

echo "Pulling latest changes from GitHub repository..."
git pull origin main

echo "Creating necessary directories..."
mkdir -p ~/traccar/backend ~/traccar/webapp ~/traccar/certs ~/traccar/nginx ~/traccar/backend/conf

echo "Copying Dockerfiles and Nginx configuration..."
cp backend/Dockerfile.backend ~/traccar/backend/Dockerfile
cp webapp/Dockerfile.webapp ~/traccar/webapp/Dockerfile
cp nginx/nginx.conf ~/traccar/nginx/nginx.conf

echo "Generating self-signed SSL certificates..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/traccar/certs/selfsigned.key -out ~/traccar/certs/selfsigned.crt -subj "/CN=${EC2_PUBLIC_IP}"

echo "Configuring Nginx with EC2 Public IP..."
sed -i "s/\${EC2_PUBLIC_IP}/${EC2_PUBLIC_IP}/g" ~/traccar/nginx/nginx.conf

cd ~/traccar/backend

if [ -d "traccar" ]; then
    echo "Traccar directory already exists. Removing all contents..."
    rm -rf ~/traccar/backend/*  # Remove all files and directories, including hidden ones
fi

echo "Cloning Traccar repository..."
git clone --recursive https://github.com/traccar/traccar.git .

echo "Copying traccar.xml configuration file..."
cp ~/traccar/backend/setup/traccar.xml ~/traccar/backend/conf/traccar.xml

cd ~/traccar

echo "Building and starting Docker containers..."
docker-compose up -d --build

echo "Setup complete! Access your Traccar application at https://${EC2_PUBLIC_IP} or your server's IP."