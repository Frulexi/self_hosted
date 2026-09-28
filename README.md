# Enterprise Homelab & Microservices Orchestration with Ansible

A production-grade homelab repository automating operating system hardening, Docker daemon provisioning, and containerized microservice deployments using **Ansible** and **Docker Compose**.

This repository mirrors an enterprise GitOps workflow: system baselines are enforced declaratively, secrets are isolated via Ansible Vault, and containerized services are dynamically discovered and orchestrated with zero downtime.

---

## 🏛️ Architecture & Workflow

```
                        [ Ansible Control Node ]
                                   │
                  ┌────────────────┴────────────────┐
                  ▼                                 ▼
         [ Security Hardening ]             [ Docker Engine ]
          - Non-standard SSH Port            - JSON Logging & Max Size
          - Key-only Auth / No Root          - Shared Bridge Networks
          - Stateful UFW Firewall            - Persistent Data Dirs
          - Fail2ban Intrusion Defense       - Systemd Service Tuning
                  │                                 │
                  └────────────────┬────────────────┘
                                   ▼
                   [ Automated Service Deployment ]
                  (Scans services/ directory tree)
                                   │
      ┌──────────────┬─────────────┼─────────────┬──────────────┐
      ▼              ▼             ▼             ▼              ▼
 [ Traefik ]   [ Authentik ]  [ Homepage ]  [ Snipe-IT ]  [ Monitoring ]
  Reverse Proxy  IAM / SSO     Application    IT Asset      Grafana, Alloy,
  & Auto-SSL     Provider      Dashboard      Management    Prometheus, Loki
```

---

## 📂 Repository Structure

```
.
├── ansible/
│   ├── ansible.cfg                    # Global Ansible defaults and vault configuration
│   ├── group_vars/
│   │   └── all.yml                    # Global security and Docker baseline variables
│   ├── inventory/
│   │   ├── production/                # Production host inventory and environment overrides
│   │   │   ├── hosts.ini
│   │   │   └── group_vars/
│   │   │       ├── homelab.yml
│   │   │       └── all/vault.yml      # Encrypted credentials (template provided)
│   │   └── staging/                   # Staging environment inventory
│   ├── playbooks/
│   │   ├── hardening.yml              # Applies security baseline (SSH, UFW, Fail2ban)
│   │   ├── docker-setup.yml           # Installs and configures Docker engine
│   │   └── deploy-services.yml        # Deploys container stacks and manages lifecycles
│   └── roles/
│       ├── security/                  # OS hardening and intrusion prevention role
│       ├── docker/                    # Docker installation, storage, and daemon tuning
│       ├── docker_service/            # Auto-discovers and deploys compose projects
│       └── docker-cleanup/            # Prunes stale images, orphan volumes, and cache
│
└── services/                          # Selected containerized services
    ├── traefik/                       # Edge reverse proxy with automated SSL
    ├── authentik/                     # Identity and access management (SSO)
    ├── homepage/                      # Centralized service dashboard
    ├── snipe-it/                      # IT Asset Management (ITAM) platform
    ├── monitoring/                    # Observability (Prometheus, Grafana, Alloy, Loki)
    └── twingate/                      # Zero-trust remote access connector
```

---

## 🛡️ Featured Services

Each service in the `services/` directory is self-contained with its own `docker-compose.yml`, optional configuration directories, and `.env.example` templates:

- 🌐 **Traefik v3**: Cloud-native reverse proxy handling HTTPS termination, automatic SSL/TLS certificate generation via Cloudflare DNS challenge, and dynamic routing to internal container networks.
- 🔐 **Authentik**: Enterprise-grade Identity and Access Management (IAM) provider enabling Single Sign-On (SSO), OAuth2, and multi-factor authentication for self-hosted apps.
- 📊 **Monitoring Stack**: Complete observability suite featuring **Prometheus** for metrics scraping, **Grafana** for visualizations, **Grafana Alloy** for telemetry, and **Loki** for centralized log collection.
- 📦 **Snipe-IT**: IT Asset Management system used to track physical hardware, network devices, accessories, and maintenance lifecycles.
- 🧭 **Homepage**: Modern, responsive dashboard displaying real-time system metrics, container statuses, and quick navigation links.
- 🔒 **Twingate**: Zero Trust Software-Defined Perimeter (SDP) connector enabling encrypted, direct remote administrative access without exposing open firewall ports.

---

## 🚀 Getting Started

### 1. Prerequisites
- **Ansible Core (v2.14+)** on the control machine.
- Target host running **Ubuntu Server (22.04 / 24.04 LTS)** or **Debian (12 Bookworm)**.
- SSH key-based access to the target host.

### 2. Configure Inventory & Variables
Edit the target host in `ansible/inventory/production/hosts.ini`:

```ini
[homelab]
prod-vm1 ansible_host=192.168.1.100 ansible_port=1022

[homelab:vars]
ansible_user=admin
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

### 3. Setup Secrets with Ansible Vault
A sanitized template is provided at `ansible/inventory/production/group_vars/all/vault.yml`. Add your credentials and encrypt the file:

```bash
# Encrypt your vault file
ansible-vault encrypt ansible/inventory/production/group_vars/all/vault.yml

# Or create a vault password file (~/.vault_pass.txt) and reference it in ansible.cfg
```

### 4. Execute Playbooks

```bash
# Step 1: Apply security hardening baseline (SSH, UFW, Fail2ban)
ansible-playbook ansible/playbooks/hardening.yml

# Step 2: Install and configure Docker Engine
ansible-playbook ansible/playbooks/docker-setup.yml

# Step 3: Discover and deploy all services
ansible-playbook ansible/playbooks/deploy-services.yml
```

---

## 🔒 Security Best Practices

- **Zero Open Ports**: All external web access routes through encrypted Cloudflare Tunnels and Twingate SDP. No inbound firewall ports are opened to the public internet.
- **Strict Network Isolation**: Distinct Docker bridge networks (`traefik_network`, `monitoring_network`, `authentik_network`, etc.) isolate container communication and prevent cross-stack lateral movement.
- **Version-Controlled Sanitization**: All real secrets, certificates, and IP addresses are completely isolated via `.gitignore` and managed using encrypted Ansible Vault entries.
