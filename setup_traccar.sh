#!/bin/bash

# Stop script on error
set -e

# Load environment variables
source .env

# Pull the latest version of the repository
git pull origin main

# Stop and remove any running containers
docker-compose down

# Generate self-signed SSL certificates
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/selfsigned.key -out certs/selfsigned.crt -subj "/CN=${EC2_PUBLIC_IP}"

# Build and run Docker containers
docker-compose up -d --build