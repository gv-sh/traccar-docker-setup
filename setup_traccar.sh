#!/bin/bash

# Stop script on error
set -e

# Load environment variables
source .env

# Update the repository
echo "Updating Traccar repository..."
git pull origin main

# Generate self-signed SSL certificates
echo "Generating self-signed SSL certificates..."
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/selfsigned.key -out certs/selfsigned.crt -subj "/CN=${EC2_PUBLIC_IP}"

# Replace placeholder in nginx.conf with actual EC2 public IP
echo "Configuring Nginx with EC2 Public IP..."
sed -i "s/\${EC2_PUBLIC_IP}/${EC2_PUBLIC_IP}/g" nginx/nginx.conf

# Build and run Docker containers
echo "Building and starting Docker containers..."
docker-compose up -d --build

echo "Setup complete! Access your Traccar application at https://${EC2_PUBLIC_IP} or your server's IP."