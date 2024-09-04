#!/bin/bash

# Stop script on error
set -e

# Function to display a progress bar
show_progress() {
    local steps=$1
    local current=$2
    local bar_length=30
    local completed=$((current * bar_length / steps))
    local remaining=$((bar_length - completed))

    printf "\rStep %d/%d: [" $current $steps
    printf "%0.s#" $(seq 1 $completed)
    printf "%0.s-" $(seq 1 $remaining)
    printf "]"
}

# Total number of steps
total_steps=5
current_step=0

# Load environment variables
current_step=$((current_step + 1))
show_progress $total_steps $current_step
if [ -f .env ]; then
    echo " Loading environment variables..."
    source .env
else
    echo " Error: .env file not found."
    exit 1
fi

# Update the repository
current_step=$((current_step + 1))
show_progress $total_steps $current_step
echo " Updating Traccar repository..."
git pull origin main
if [ $? -ne 0 ]; then
    echo " Failed to update the repository. Please check your network connection."
    exit 1
fi

# Generate self-signed SSL certificates
current_step=$((current_step + 1))
show_progress $total_steps $current_step
echo " Generating self-signed SSL certificates..."
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/selfsigned.key -out certs/selfsigned.crt -subj "/CN=${EC2_PUBLIC_IP}"
if [ $? -ne 0 ]; then
    echo " Failed to generate self-signed SSL certificates."
    exit 1
fi

# Replace placeholder in nginx.conf with actual EC2 public IP
current_step=$((current_step + 1))
show_progress $total_steps $current_step
echo " Configuring Nginx with EC2 Public IP..."
sed -i "s/\${EC2_PUBLIC_IP}/${EC2_PUBLIC_IP}/g" nginx/nginx.conf
if [ $? -ne 0 ]; then
    echo " Failed to configure Nginx with EC2 Public IP."
    exit 1
fi

# Build and run Docker containers
current_step=$((current_step + 1))
show_progress $total_steps $current_step
echo " Building and starting Docker containers..."
docker-compose up -d --build
if [ $? -ne 0 ]; then
    echo " Failed to build and start Docker containers."
    exit 1
fi

# Completion message
show_progress $total_steps $total_steps
echo " Setup complete! Access your Traccar application at https://${EC2_PUBLIC_IP} or your server's IP."