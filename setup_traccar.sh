#!/bin/bash

# Stop script on error
set -e

# Define the Traccar version and repository
TRACCAR_VERSION="6.4"
REPO_URL="https://github.com/traccar/traccar.git"

# Create necessary directory structure
mkdir -p backend/traccar webapp nginx certs

# Clone the Traccar repository with submodules into the backend/traccar directory
echo "Cloning Traccar repository..."
git clone --recursive $REPO_URL backend/traccar

# Generate self-signed SSL certificates
echo "Generating self-signed SSL certificates..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/selfsigned.key -out certs/selfsigned.crt -subj "/CN=localhost"

# Copy the traccar.xml file from the setup directory in the cloned repository
cp backend/traccar/setup/traccar.xml backend/traccar/conf/

# Build and run Docker containers
echo "Building and starting Docker containers..."
docker-compose up -d --build

echo "Setup complete! Access your Traccar application at https://localhost or your server's IP."