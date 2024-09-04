#!/bin/bash

set -e

source .env

echo "Pulling latest changes from GitHub repository..."
git pull origin main

echo "Generating self-signed SSL certificates..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/selfsigned.key -out certs/selfsigned.crt -subj "/CN=${EC2_PUBLIC_IP}"

echo "Configuring Nginx with EC2 Public IP..."
sed -i "s/\${EC2_PUBLIC_IP}/${EC2_PUBLIC_IP}/g" nginx/nginx.conf

# Ensure backend directory is empty for git clone
if [ -d "~/traccar/backend" ]; then
    echo "Traccar backend directory already exists. Removing it..."
    rm -rf ~/traccar/backend
fi

echo "Creating a fresh backend directory..."
mkdir -p ~/traccar/backend

cd ~/traccar/backend

echo "Cloning Traccar repository..."
git clone --recursive https://github.com/traccar/traccar.git .

# Change back to the directory where docker-compose.yml is located
cd ~/traccar-docker-setup

echo "Building and starting Docker containers..."
docker-compose up -d --build

echo "Setup complete! Access your Traccar application at https://${EC2_PUBLIC_IP} or your server's IP."