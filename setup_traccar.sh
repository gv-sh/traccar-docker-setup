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
mkdir -p $CERTS_DIR
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $CERTS_DIR/selfsigned.key -out $CERTS_DIR/selfsigned.crt -subj "/CN=${EC2_PUBLIC_IP}"

echo "Configuring Nginx with EC2 Public IP..."
sed -i "s/\${EC2_PUBLIC_IP}/${EC2_PUBLIC_IP}/g" $NGINX_DIR/nginx.conf

echo "Cloning Traccar repository..."
git clone --recursive https://github.com/traccar/traccar.git $APP_DIR

echo "Setting up Traccar configuration..."
mkdir -p $CONF_DIR
if [ ! -f $CONF_DIR/traccar.xml ]; then
    echo "Copying default traccar.xml configuration..."
    cp $APP_DIR/setup/traccar.xml $CONF_DIR/traccar.xml
fi

# Update database configuration in traccar.xml
sed -i 's|<entry key="database.url">.*</entry>|<entry key="database.url">'${DATABASE_URL}'</entry>|' $CONF_DIR/traccar.xml
sed -i 's|<entry key="database.user">.*</entry>|<entry key="database.user">'${DATABASE_USER}'</entry>|' $CONF_DIR/traccar.xml
sed -i 's|<entry key="database.password">.*</entry>|<entry key="database.password">'${DATABASE_PASSWORD}'</entry>|' $CONF_DIR/traccar.xml

echo "Setting up webapp..."
cp -r $APP_DIR/traccar-web/* $WEBAPP_DIR/

echo "Building and starting Docker containers..."
docker-compose up -d --build

echo "Setup complete! Access your Traccar application at https://${EC2_PUBLIC_IP}"