# Enterprise-Grade Self-Hosted Infrastructure & Staging Lab

This repository showcases the Infrastructure-as-Code (IaC) blueprints and container orchestration configurations that power my 24/7 dedicated production and staging homelab. It serves as a sandbox for testing deployment reproducibility, automation pipelines, and robust zero-trust security layers before migrating services to live staging environments.

---

## 🗺️ Architectural Overview

My hybrid-cloud homelab combines physical hardware virtualization, enterprise-level network segmentation, and modern containerized orchestration into a resilient, high-uptime system.

```
                   [ Edge Security / Gateway ]
                                │
               [ UniFi Cloud Gateway Ultra (UCG) ]
                 - VLAN 10: Trusted Devices
                 - VLAN 20: Isolated Lab & Staging
                 - VLAN 30: Restricted IoT
                                │
         ┌──────────────────────┴──────────────────────┐
         ▼                                             ▼
  [ Twingate SDP ]                            [ Cloudflare Tunnel ]
  (Secure remote access)                      (Zero-Trust web access)
         │                                             │
         └──────────────────────┬──────────────────────┘
                                ▼
                       [ Proxmox VE Node ]
                                │
         ┌──────────────────────┴──────────────────────┐
         ▼                                             ▼
  [ LXC Containers ]                            [ Ubuntu VM (prod-vm) ]
   - Snipe-IT ITAM                              - Docker Engine
   - Home Assistant                              - Portainer CE
                                                 - NGINX Proxy Manager
                                                 - Nextcloud Stack
```

---

## 🛠️ Infrastructure Stack

### 1. Bare-Metal Hypervisor (Proxmox VE)
- **Virtualization Core**: Running Proxmox VE to host specialized Virtual Machines (VMs) and lightweight, high-performance Linux Containers (LXCs). This allows for full resource allocation control and rapid environment cloning.
- **Orchestration**: System updates, template provisioning, and package installations are managed via declarative **Ansible Playbooks** with credential encryption managed via **Ansible Vault**.

### 2. Network Engineering & Zero-Trust Security
- **Physical Gateway**: Powered by a **UniFi Cloud Gateway Ultra (UCG-Ultra)** managing multiple isolated VLAN subnets with stateful firewall rules to enforce least-privilege traffic flow.
- **Access Control**: No public inbound ports are exposed.
  - **Twingate Software-Defined Perimeter (SDP)**: Provides secure, encrypted peer-to-peer tunnels directly to private management endpoints for administrators.
  - **Cloudflare Tunnels**: Proxies secure public HTTP traffic to selected public-facing microservices with automated edge-level DDoS protection.

### 3. Declarative Container Staging Stack (Terraform Managed)
This repository contains the **Terraform** configuration (`main.tf`) that automates the deployment of our core Docker microservices stack:

- 🔖 **Flame**: A minimal, fast, and centralized homepage dashboard for single-pane-of-glass access to self-hosted web applications.
- 🛡️ **NGINX Proxy Manager**: A reverse proxy that handles incoming traffic routing, automated Let's Encrypt SSL/TLS certificate acquisition and renewal, and custom header injections.
- ☁️ **Nextcloud**: A high-performance, private cloud file-sharing and collaboration platform.
- 🗄️ **MariaDB**: A hardened relational database service configured specifically to back the Nextcloud application with optimized transaction logs.
- ⚙️ **Portainer CE**: A lightweight web-based console enabling GUI management and real-time telemetry monitoring for local Docker containers.

---

## 🚀 Local Deployment Guide

### Prerequisites
- [Terraform CLI (v1.0+)](https://developer.hashicorp.com/terraform/downloads)
- [Docker Engine (v20.10+)](https://docs.docker.com/engine/install/)
- Docker daemon accessible to your local user shell.

### 1. Configuration Setup
Create a private `terraform.tfvars` file in the root of this directory. This file is automatically ignored by Git (per `.gitignore`) to ensure your secrets never leak.

```hcl
# Example terraform.tfvars template
host_path      = "/opt/homelab/storage"  # Root directory on your host for persistent volume mounts
admin_user     = "sys_admin"             # Default administrator username for Nextcloud and Database
admin_password = "your-secure-password"  # Main administrator password
root_password  = "your-root-db-password" # Hardened MariaDB root database password
```

### 2. Initialization & Execution
Initialize the provider plugins and apply the infrastructure configuration:

```bash
# Initialize Terraform
terraform init

# Validate the syntax of the config files
terraform validate

# Plan and preview the actions Terraform will perform
terraform plan

# Apply the configurations and spin up the containers
terraform apply
```

*Confirm the action by typing `yes` when prompted.*

### 3. Exited / Running Ports
Once deployed, services will be bound to the following local container-mode interfaces:
- **Flame Dashboard**: `http://localhost:5005`
- **Nextcloud Portal**: `http://localhost:5080`
- **NGINX Admin Console**: `http://localhost:81`
- **Portainer Dashboard**: `http://localhost:801` (HTTPS available on `9443`)

---

## 🔒 Security & Secrets Hardening

- **Docker Socket Isolation**: The Docker socket (`/var/run/docker.sock`) is mounted only into containers requiring cluster-level event metrics (Flame, Portainer) under strict access rules.
- **Sensitive Variables**: All critical passwords, API secrets, and storage paths are declared as variables with `sensitive = true` in `variables.tf`, preventing them from displaying in standard console outputs or logs.
- **Persistent Volumes**: All container data is externalized using defined Docker volumes and centralized host mounts to simplify scheduled offline backups and state preservation.

---

## 📈 Future Staging Plans

- 📊 **Monitoring Architecture**: Integrating Prometheus, cAdvisor, and Grafana to capture node-level and container-level system metrics (CPU, Memory, Network).
- 🪵 **Log Management**: Setting up a centralized syslog/ELK stack (Elasticsearch, Logstash, Kibana) for proactive audit logs and authentication monitoring.
