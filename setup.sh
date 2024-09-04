#!/bin/bash

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y docker.io docker-compose

# Clone the repository
git clone https://github.com/your-username/traccar-docker-setup.git
cd traccar-docker-setup

# Create a directory for SSL certificates
mkdir -p certs

# Generate self-signed SSL certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout certs/privkey.pem \
    -out certs/fullchain.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=3.95.219.117"

# Set proper permissions for the certificates
sudo chown -R $USER:$USER certs
chmod 600 certs/privkey.pem

# Start the Docker containers
sudo docker-compose up -d

echo "Traccar setup complete. Access the web interface at https://3.95.219.117"