# Docker SelfHosted Lab Infrastructure with Terraform

This repository showcases a Docker-powered self-hosted lab managed by Terraform. This setup is intended for testing demonstration and learning, with planned changes.

## Table Of Contentes 
- [Overview](#overview)
- [Containers](#Containers)
- [Networks and Volumes](#Networks-and-Volumes)
- [Prerequisites](#Prerequisites)
- [Setup](#Setup)
- [Security and Best Practices](#Security-and-Best-Practices)
- [Future Plans](#Future-Plans)

## Overview 
This Terraform configuration deploys a collection of Docker containers, Each container serves a specific purpose. 

## Containers 
- Flame: Start page for centralized access to applications
- NGINX Proxy Manager: Reverse proxy with SSL capabilities
- NextCloud: Self-hosted file-sharing service
- MariaDB: Database service for Nextcloud
- Portainer: Docker container management UI

## Networks and Volumes
- Docker Volumes: Persistent storage for Nextcloud, MariaDB, and Portainer.
- Docker Networks: Isolated Docker network for internal communication.

## Prerequisites
- Terraform: Version 1.0+ [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Docker: Version 20+ [Install Docker](https://docs.docker.com/engine/install/)

## Setup 
1. Clone the repository:
   ```bash
   git clone https://github.com/Frulexi/self_hosted.git
   cd self_hosted
   ```
2. Create a terraform.tfvars File Add your specific configuration in a terraform.tfvars file based on the [example](#Example-terraform.tfvars).
   ```bash
   terraform init
   ```
3. Apply the Configuration
   ```bash
   terrafom apply
   ```
   Confirm the action with yes when prompted. Terraform will pull Docker images, create containers, set up volumes, and configure networks.

5. Access services
- Flame: http://localhost:5005
- Nextcloud: http://localhost:5080
- Portainer: http://localhost:801

## Example terraform.tfvars
```
# Define the host path for persistent data storage
host_path      = "/path/to/your/storage"
admin_password = "your_secure_admin_password"
root_password  = "your_secure_root_password"
admin_user     = "nextcloud_admin_user"
```
## Notes:
- Replace /path/to/your/storage with the path on your system where you want persistent data to be stored.
- Use strong passwords for admin_password and root_password to ensure security.

## Security and Best Practices
- Docker Socket Exposure: The Docker socket is mounted for flame and portainer containers. Be cautious with this, as it grants extensive permissions.
- Environment Variables: Sensitive values like passwords are stored in terraform.tfvars, which should not be committed to version control. Use .gitignore to keep it private.

## Future Plans
- Grafana + Prometheus: To provide metrics and performance monitoring.
- cAdvisor: For container-level monitoring of CPU, memory, and network usage.
- ELK Stack (Elasticsearch, Logstash, Kibana): For advanced log analysis

