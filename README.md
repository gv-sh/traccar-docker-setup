# Traccar Docker Setup

This repository contains Docker configuration files to set up Traccar on an AWS EC2 instance using four Docker containers:

1. Front-end (Traccar Web)
2. Back-end (Traccar Server)
3. Database (MySQL)
4. Database GUI (Adminer)
5. Nginx proxy for HTTPS

## Prerequisites

- AWS EC2 instance running Ubuntu
- Docker and Docker Compose installed

## Setup Instructions

1. Clone this repository to your EC2 instance.
2. Run the `setup.sh` script:

   ```
   chmod +x setup.sh
   ./setup.sh
   ```

3. The script will install Docker, set up self-signed SSL certificates, and start the containers.
4. Access the Traccar web interface at `https://98.81.195.221`.
5. Access the Administrator database GUI at `http://98.81.195.221:8080`.

## Configuration

- The `nginx.conf` file is configured to use the EC2 instance's public IP (98.81.195.221).
- Self-signed SSL certificates are generated in the `certs` directory.
- Adjust database credentials in `docker-compose.yml` if needed.

## Security Note

This setup uses self-signed SSL certificates, which may trigger security warnings in web browsers. For production use, consider using a proper SSL certificate from a trusted certificate authority.