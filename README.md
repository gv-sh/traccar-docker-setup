# Traccar Docker Setup

This repository contains the necessary files to set up a Traccar server with a web interface using Docker on an EC2 instance.

## Prerequisites

- An AWS account
- Basic knowledge of AWS EC2 and Docker

## Step-by-step Setup Instructions

1. Launch an EC2 instance:
   - Use Ubuntu Server 22.04 LTS (or the latest LTS version)
   - Choose an instance type (t2.micro is sufficient for testing)
   - Configure a security group with the following inbound rules:
     - SSH (port 22) from your IP
     - HTTP (port 80) from anywhere
     - HTTPS (port 443) from anywhere
     - Custom TCP (port 8082) from anywhere
   - Launch the instance and save the key pair

2. Connect to your EC2 instance:
   ```
   ssh -i /path/to/your-key.pem ubuntu@your-ec2-public-ip
   ```

3. Update the system and install Docker:
   ```
   sudo apt update && sudo apt upgrade -y
   sudo apt install docker.io docker-compose -y
   ```

4. Clone this repository:
   ```
   git clone https://github.com/gv-sh/traccar-docker-setup.git
   cd traccar-docker-setup
   ```

5. Create and edit the `.env` file:
   ```
   cp .env.example .env
   nano .env
   ```
   Update the `PUBLIC_IP` with your EC2 instance's public IP or domain name.

6. Generate SSL certificates:
   ```
   mkdir -p traccar-docker-setup/certs
   sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout traccar-docker-setup/certs/privkey.pem \
     -out traccar-docker-setup/certs/fullchain.pem \
     -subj "/C=US/ST=State/L=City/O=Organization/CN=your-ec2-public-ip"
   ```
   Replace `your-ec2-public-ip` with your actual EC2 public IP or domain name.

7. Build and start the Docker containers:
   ```
   docker-compose up -d
   ```

8. Check if all containers are running:
   ```
   docker-compose ps
   ```

9. Access your Traccar server:
   - Web interface: `https://your-ec2-public-ip`
   - Traccar server: `http://your-ec2-public-ip:8082`
   - Adminer (database management): `http://your-ec2-public-ip:8080`

## Troubleshooting

- If you encounter any issues, check the logs of the specific service:
  ```
  docker-compose logs [service_name]
  ```
  Replace `[service_name]` with traccar, frontend, db, adminer, or nginx.

- Ensure all ports specified in the `.env` file are open in your EC2 security group.

- If you need to rebuild the containers after making changes:
  ```
  docker-compose down
  docker-compose up --build -d
  ```

## Maintenance

- To stop the services:
  ```
  docker-compose down
  ```

- To update the services (after pulling new changes):
  ```
  docker-compose pull
  docker-compose up -d
  ```

- To view real-time logs:
  ```
  docker-compose logs -f
  ```
