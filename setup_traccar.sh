#!/bin/bash

# Stop script on error
set -e

# Load environment variables
source .env

# Pull the latest changes from the repository
echo "Pulling the latest changes from the setup repository..."
git pull origin main

# Create a directory for Traccar
echo "Creating directories for Traccar..."
mkdir -p ~/traccar/backend ~/traccar/webapp ~/traccar/certs ~/traccar/nginx

# Copy Dockerfiles and configuration files to the respective directories
echo "Copying configuration and Dockerfiles to the Traccar directories..."
cp backend/Dockerfile.backend ~/traccar/backend/Dockerfile
cp webapp/Dockerfile.webapp ~/traccar/webapp/Dockerfile
cp nginx/nginx.conf ~/traccar/nginx/nginx.conf

# Generate self-signed SSL certificates
echo "Generating self-signed SSL certificates..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/traccar/certs/selfsigned.key -out ~/traccar/certs/selfsigned.crt -subj "/CN=${EC2_PUBLIC_IP}"

# Replace placeholder in nginx.conf with actual EC2 public IP
echo "Configuring Nginx with EC2 Public IP..."
sed -i "s/\${EC2_PUBLIC_IP}/${EC2_PUBLIC_IP}/g" ~/traccar/nginx/nginx.conf

# Build and run Docker containers
echo "Building and starting Docker containers..."
docker-compose up -d --build

echo "Setup complete! Access your Traccar application at https://${EC2_PUBLIC_IP} or your server's IP."