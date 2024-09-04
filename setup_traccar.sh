#!/bin/bash

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo ".env file not found. Please create it with the necessary variables."
    exit 1
fi

echo "Pulling latest changes from GitHub repository..."
git pull origin main

echo "Generating self-signed SSL certificates..."
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/selfsigned.key -out certs/selfsigned.crt -subj "/CN=${EC2_PUBLIC_IP}"

echo "Configuring Nginx with EC2 Public IP..."
sed -i "s/\${EC2_PUBLIC_IP}/${EC2_PUBLIC_IP}/g" nginx/nginx.conf

echo "Cloning Traccar repository..."
mkdir -p backend
git clone --recursive https://github.com/traccar/traccar.git backend/traccar

echo "Setting up Traccar configuration..."
mkdir -p conf
if [ ! -f conf/traccar.xml ]; then
    echo "Copying default traccar.xml configuration..."
    cp backend/traccar/setup/traccar.xml conf/traccar.xml
fi

# Update database configuration in traccar.xml
sed -i 's|<entry key="database.url">.*</entry>|<entry key="database.url">'${DATABASE_URL}'</entry>|' conf/traccar.xml
sed -i 's|<entry key="database.user">.*</entry>|<entry key="database.user">'${DATABASE_USER}'</entry>|' conf/traccar.xml
sed -i 's|<entry key="database.password">.*</entry>|<entry key="database.password">'${DATABASE_PASSWORD}'</entry>|' conf/traccar.xml

echo "Building and starting Docker containers..."
docker-compose up -d --build

echo "Setup complete! Access your Traccar application at https://${EC2_PUBLIC_IP}"