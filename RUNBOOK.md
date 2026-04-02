# 📖 RUNBOOK: Immutable Infrastructure Deployment

> **Operational Guide for Zero-Downtime, Reproducible Infrastructure Deployment**

[![Version](https://img.shields.io/badge/Version-2.0-blue?style=flat-square)](https://semver.org)
[![IaC](https://img.shields.io/badge/Immutable-Infrastructure-orange?style=flat-square)](https://www.terraform.io)
[![Vagrant](https://img.shields.io/badge/Vagrant-2.4.0+-1563FF?style=flat-square)](https://www.vagrantup.com)
[![Ansible](https://img.shields.io/badge/Ansible-9.0+-EE0000?style=flat-square)](https://www.ansible.com)
[![Docker](https://img.shields.io/badge/Docker-24.0+-2496ED?style=flat-square)](https://www.docker.com)
[![WSL 2](https://img.shields.io/badge/WSL-2.0+-4D4D4D?style=flat-square)](https://learn.microsoft.com/en-us/windows/wsl/)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Phase 1: Clean State](#phase-1-clean-state)
4. [Phase 2: Environment Setup](#phase-2-environment-setup)
5. [Phase 3: Infrastructure Deployment](#phase-3-infrastructure-deployment)
6. [Phase 4: Configuration Management](#phase-4-configuration-management)
7. [Phase 5: Validation & Testing](#phase-5-validation--testing)
8. [Troubleshooting](#troubleshooting)
9. [Recovery Procedures](#recovery-procedures)

---

## 📚 Overview

This runbook provides **step-by-step operational procedures** for deploying an immutable infrastructure stack:

- **Host:** Windows 11 + WSL 2 (control plane)
- **Orchestrator:** Vagrant with Docker provider
- **Provisioner:** Ansible (configuration management)
- **Runtime:** Docker (containerization)
- **Workload:** Nginx on Alpine Linux

### What "Immutable" Means Here

Every deployment:
- ✅ Starts from a clean slate
- ✅ Follows the same playbook exactly
- ✅ Can be destroyed and rebuilt at will
- ✅ Requires zero manual configuration
- ✅ Is fully traceable in version control

---

## 🏛️ System Architecture

```
Windows 11 (Host)
    ↓
    └─── WSL 2 (Linux Subsystem)
            ├─ Terminal / Vagrant CLI
            ├─ Ansible Control Node (SSH)
            └─ Docker Client (via Windows bridge)
                    ↓
                    └─── Docker Desktop (Windows)
                            ↓
                            └─── Docker Container (Ubuntu 22.04)
                                    ├─ SSH Server (Port 2200)
                                    ├─ Docker Engine (DinD)
                                    └─ Application Stack
                                        └─ Nginx:Alpine
```

**Data Flow:**
1. WSL terminal executes `vagrant up`
2. Vagrant communicates with Docker Desktop via Windows bridge
3. Docker Desktop creates Ubuntu container
4. Ansible connects via SSH (Port 2200)
5. Configuration applied → Infrastructure ready

---

## ✅ Prerequisites

Before starting, verify your system is ready:

| Component | Minimum Version | Check Command |
|-----------|-----------------|----------------|
| **Windows** | 10 (22H2) or 11 | `winver` |
| **WSL 2** | 2.0.0+ | `wsl --version` |
| **Docker Desktop** | 24.0+ | `docker --version` |
| **Vagrant** | 2.4.0+ | `vagrant --version` |
| **Ansible** | 9.0+ | `ansible --version` |
| **SSH Client** | Any | `ssh -V` |
| **Git** | Any | `git --version` |

### Installation Checklist

```bash
# Verify all tools are installed and working
wsl --version          # Should show 2.x.x
docker --version       # Should show 24.0+
vagrant --version      # Should show 2.4.0+
ansible --version      # Should show 9.0+

# Test Docker connectivity
docker ps              # Should show empty container list

# Test SSH
ssh localhost -V       # Should show OpenSSH version
```

**If any tool is missing:** Install from official sources
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Vagrant](https://www.vagrantup.com/downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

---

## 🧹 Phase 1: Clean State

⚠️ **WARNING:** This step removes ALL Docker containers and images. Only run if you want a completely clean system.

### Option A: Full Nuclear Reset

```bash
#!/bin/bash
set -e

echo "🧹 Starting complete system cleanup..."

# Step 1: Remove all running containers
echo "   • Removing Docker containers..."
docker rm -f $(docker ps -aq) 2>/dev/null || true

# Step 2: Remove all images
echo "   • Removing Docker images..."
docker rmi $(docker images -q) -f 2>/dev/null || true

# Step 3: Clean Vagrant state
echo "   • Cleaning Vagrant state..."
vagrant destroy -f 2>/dev/null || true
rm -rf .vagrant/

# Step 4: Remove SSH key fingerprints
echo "   • Clearing SSH known_hosts..."
ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "[127.0.0.1]:2200" 2>/dev/null || true

# Step 5: Prune Docker system
echo "   • Running Docker system prune..."
docker system prune -a -f 2>/dev/null || true

echo "✅ Clean state achieved! System ready for fresh deployment."
```

### Option B: Minimal Reset (Vagrant only)

```bash
# Destroy just Vagrant resources, keep Docker images
vagrant destroy -f
rm -rf .vagrant/
```

### Option C: Smart Reset (Keep images, clean containers)

```bash
# Useful for repeated testing without re-downloading
docker rm -f $(docker ps -aq) 2>/dev/null || true
vagrant destroy -f
rm -rf .vagrant/
```

---

## 🔧 Phase 2: Environment Setup

### Step 1: WSL Configuration

WSL must communicate with Docker Desktop running on Windows. Set these environment variables:

```bash
# Enable WSL access to Windows Docker
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"

# Add Windows System32 to PATH (for Windows binaries)
export PATH="$PATH:/mnt/c/Windows/System32"

# Optional: Add Windows PowerShell
export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
```

**To make these persistent, add to `~/.bashrc`:**

```bash
cat >> ~/.bashrc <<'EOF'

# ========== Docker & Vagrant WSL Configuration ==========
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Windows/System32"
export ANSIBLE_HOST_KEY_CHECKING=False

# ========== End Configuration ==========
EOF

source ~/.bashrc
```

### Step 2: Verify Docker Connectivity

```bash
# Test Docker socket communication
docker ps

# Expected output: Empty container list (or existing containers)
# If error: Docker Desktop not running on Windows
```

### Step 3: Clone Repository

```bash
# Clone the infrastructure repository
git clone https://github.com/jgaragorry/iac-immutable-deployment-vagrant-ansible.git

# Navigate to project
cd iac-immutable-deployment-vagrant-ansible

# Verify structure
ls -la
# Expected files: Vagrantfile, playbook.yml, RUNBOOK.md, Makefile, scripts/
```

### Step 4: Verify File Permissions

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Verify playbook YAML syntax
ansible-playbook playbook.yml --syntax-check
```

---

## 🚀 Phase 3: Infrastructure Deployment

### Launch Vagrant

```bash
# Start container infrastructure with Docker provider
vagrant up --provider=docker
```

**What happens:**
- Vagrant reads `Vagrantfile`
- Creates Ubuntu 22.04 Docker container
- Configures SSH server on port 2200
- Outputs container ID and connection info
- **Takes 30-60 seconds**

### Verify Container Status

```bash
# Check Vagrant status
vagrant status

# Expected output:
# current machine states:
# default                   running (docker)

# List running Docker container
docker ps

# Should show one container based on the Vagrantfile
```

### Quick Connectivity Test

```bash
# Test SSH connection
ssh -p 2200 root@127.0.0.1 -o StrictHostKeyChecking=no

# Inside container, verify basic tools
cat /etc/os-release
exit
```

---

## ⚙️ Phase 4: Configuration Management (Ansible)

### The "Golden Command" — Apply Configuration

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
  -i "127.0.0.1:2200," \
  playbook.yml \
  -u root \
  -e "ansible_password=root" \
  --ssh-extra-args="-o StrictHostKeyChecking=no"
```

**Breaking this down:**
| Flag | Purpose |
|------|---------|
| `ANSIBLE_HOST_KEY_CHECKING=False` | Don't prompt about SSH key verification (safe for local dev) |
| `-i "127.0.0.1:2200,"` | Inventory: single host at that IP:port (comma required!) |
| `playbook.yml` | Configuration file to apply |
| `-u root` | Connect as root user |
| `-e "ansible_password=root"` | Use password authentication (not SSH keys) |
| `--ssh-extra-args="-o StrictHostKeyChecking=no"` | Additional SSH safety flags |

### Expected Playbook Tasks

Your `playbook.yml` should include:

```yaml
---
- name: Configure immutable infrastructure
  hosts: all
  become: yes
  gather_facts: yes
  
  tasks:
    # ===== System Updates =====
    - name: Update system packages
      apt:
        update_cache: yes
        upgrade: dist
      tags: [system]
    
    # ===== Install Docker =====
    - name: Install Docker
      apt:
        name:
          - docker.io
          - docker-compose
          - curl
          - git
        state: present
      tags: [docker]
    
    # ===== Start Docker Service =====
    - name: Start Docker daemon
      systemd:
        name: docker
        state: started
        enabled: yes
      tags: [docker]
    
    # ===== Deploy Application Container =====
    - name: Deploy Nginx container
      docker_container:
        name: web_app
        image: nginx:alpine
        state: started
        restart_policy: always
        ports:
          - "80:80"
        volumes:
          - /data/nginx:/usr/share/nginx/html
      tags: [app]
    
    # ===== Validation =====
    - name: Wait for Nginx to be ready
      uri:
        url: http://localhost:80
        status_code: 200
      register: result
      until: result.status == 200
      retries: 3
      delay: 5
      tags: [validate]
```

### Monitor Ansible Execution

```bash
# Add verbosity for debugging
ansible-playbook ... -v      # Show task results
ansible-playbook ... -vv     # Show module details
ansible-playbook ... -vvv    # Show all details (very verbose)
```

### Idempotence Verification

Run the playbook a second time. If designed correctly:
- All tasks should show **ok** or **skipped** (not **changed**)
- No errors should occur
- All services remain operational

```bash
# Run again - should be idempotent
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
  -i "127.0.0.1:2200," \
  playbook.yml \
  -u root \
  -e "ansible_password=root"

# Compare output: should see "changed=0" at the end
```

---

## ✅ Phase 5: Validation & Testing

### 5.1 SSH Connectivity

```bash
# Connect to container
vagrant ssh

# Inside container, verify:
whoami                          # Should show: root
hostname                        # Should show container ID
docker --version                # Docker installed?
docker ps                       # Any containers running?

# Exit container
exit
```

### 5.2 Docker Verification

```bash
# From WSL, check Docker inside container
vagrant ssh -c "docker ps"

# Expected: Running containers (Nginx, etc.)
vagrant ssh -c "docker images"

# Expected: Images pulled for deployment
```

### 5.3 Application Smoke Test

```bash
# Run included smoke tests
bash scripts/smoke-test.sh

# Or manual HTTP test
curl -I http://localhost:80 \
  -H "Host: 127.0.0.1"

# Expected: HTTP 200 OK
```

### 5.4 Port Accessibility

```bash
# From WSL, check if Nginx is accessible
curl -s http://127.0.0.1:80 | head -20

# From Windows (if port forwarded), test in browser
# http://localhost:8080 (or whatever is mapped in Vagrantfile)
```

### 5.5 Service Health

```bash
# SSH into container and check service status
vagrant ssh -c "systemctl status docker"
vagrant ssh -c "systemctl is-active docker"

# Check Nginx logs
vagrant ssh -c "docker logs web_app | tail -20"
```

### 5.6 Persistence Verification

```bash
# Restart container to verify services auto-start
vagrant reload

# After restart, verify services are running
vagrant ssh -c "docker ps"
```

---

## 🔍 Troubleshooting

### Problem: Docker Not Found in WSL

**Symptoms:** `docker: command not found`

**Solutions:**
```bash
# 1. Check Docker Desktop is running on Windows
#    → Open Windows Start Menu → Search "Docker Desktop" → Click it

# 2. Verify PATH includes Windows binaries
echo $PATH | grep -i system32
# If not found, run:
export PATH="$PATH:/mnt/c/Windows/System32"

# 3. Test Docker socket
docker ps
```

### Problem: Vagrant Can't Connect to Docker

**Symptoms:** `Error: Unable to connect to Docker daemon`

**Solutions:**
```bash
# 1. Enable WSL interoperability
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"

# 2. Add to ~/.bashrc to persist:
echo 'export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"' >> ~/.bashrc

# 3. Restart terminal and try again
vagrant up --provider=docker
```

### Problem: SSH Connection Refused

**Symptoms:** `ssh: connect to host 127.0.0.1 port 2200: Connection refused`

**Solutions:**
```bash
# 1. Verify container is running
vagrant status

# 2. If not running, start it
vagrant up --provider=docker

# 3. Check SSH server status inside container
vagrant ssh -c "systemctl status ssh"

# 4. Clear stale SSH keys
ssh-keygen -f ~/.ssh/known_hosts -R "[127.0.0.1]:2200"

# 5. Try SSH manually with verbose output
ssh -vvv -p 2200 root@127.0.0.1
```

### Problem: Ansible Timeout

**Symptoms:** `fatal: [127.0.0.1:2200]: UNREACHABLE! => {`

**Solutions:**
```bash
# 1. Wait longer for SSH to be ready
sleep 10
vagrant ssh

# 2. Increase Ansible timeout
ansible-playbook -i "127.0.0.1:2200," playbook.yml \
  -e "ansible_connection_timeout=30" ...

# 3. Test SSH manually first
ssh -p 2200 root@127.0.0.1
```

### Problem: Playbook Fails with "Module Not Found"

**Symptoms:** `fatal: [127.0.0.1]: FAILED! => {"msg": "The following modules failed to load...`

**Solutions:**
```bash
# 1. Install required Ansible collections
ansible-galaxy collection install community.docker

# 2. Verify playbook syntax
ansible-playbook playbook.yml --syntax-check

# 3. Check Ansible version
ansible --version  # Should be 9.0+
```

### Problem: Docker Can't Download Images

**Symptoms:** `Error: Unable to pull image from registry`

**Solutions:**
```bash
# 1. Check internet connectivity inside container
vagrant ssh -c "curl https://www.google.com"

# 2. Try pulling image manually
vagrant ssh -c "docker pull nginx:alpine"

# 3. If behind proxy, configure Docker daemon.json
vagrant ssh -c "sudo vi /etc/docker/daemon.json"
# Add proxy config, restart Docker
```

### Problem: Vagrant Ignores Ansible Provisioner

**Symptoms:** `vagrant up` completes but Ansible playbook never runs

**Solutions:**
```bash
# 1. Run provisioning manually
vagrant provision

# 2. Check Vagrantfile has provisioner block:
cat Vagrantfile | grep -A 5 "provisioner"

# 3. Run with verbose output
vagrant up --provider=docker -v
```

---

## 🆘 Recovery Procedures

### Complete System Restore

If anything goes wrong, start fresh:

```bash
#!/bin/bash
echo "Starting complete recovery..."

# 1. Stop and remove Vagrant resources
vagrant destroy -f 2>/dev/null || true
rm -rf .vagrant 2>/dev/null || true

# 2. Clean Docker
docker rm -f $(docker ps -aq) 2>/dev/null || true
docker system prune -a -f 2>/dev/null || true

# 3. Clear SSH fingerprints
ssh-keygen -f ~/.ssh/known_hosts -R "[127.0.0.1]:2200" 2>/dev/null || true

# 4. Restart Docker Desktop (from Windows)
# Close Docker, wait 10 seconds, reopen

# 5. Re-deploy
sleep 10
vagrant up --provider=docker

echo "✅ Recovery complete!"
```

### Partial Recovery (Keep Images)

```bash
# Useful for debugging without re-pulling everything
vagrant destroy -f
rm -rf .vagrant/
vagrant up --provider=docker
```

### Network Reset

```bash
# If Docker networking is broken
docker network prune -f
vagrant destroy -f
docker system prune -a -f
# Restart Docker Desktop
vagrant up --provider=docker
```

---

## 📊 Health Check Dashboard

Run this script regularly to verify system health:

```bash
#!/bin/bash

echo "=== INFRASTRUCTURE HEALTH CHECK ==="
echo ""

echo "✓ Docker Status:"
docker ps -q | wc -l
echo "  Containers running"

echo ""
echo "✓ Vagrant Status:"
vagrant status

echo ""
echo "✓ SSH Connectivity:"
if ssh -p 2200 root@127.0.0.1 -o ConnectTimeout=3 -o StrictHostKeyChecking=no "exit" 2>/dev/null; then
  echo "  ✅ SSH: Connected"
else
  echo "  ❌ SSH: Disconnected"
fi

echo ""
echo "✓ Application Status:"
curl -s -I http://localhost:80 | head -1

echo ""
echo "✓ Ansible Control:"
ansible all -i "127.0.0.1:2200," -u root -e "ansible_password=root" \
  --ssh-extra-args="-o StrictHostKeyChecking=no" -m ping

echo ""
echo "=== END HEALTH CHECK ==="
```

---

## 📞 Getting Help

If you're stuck:

1. **Check the logs:**
   ```bash
   vagrant ssh -c "journalctl -xe"    # System logs
   vagrant ssh -c "docker logs web_app"  # App logs
   ```

2. **Enable debug mode:**
   ```bash
   vagrant up --provider=docker -v
   ansible-playbook ... -vvv
   ```

3. **Test components individually:**
   ```bash
   docker ps              # Docker working?
   vagrant status         # Vagrant aware?
   ssh -p 2200 ...        # SSH accessible?
   ```

4. **Contact support:**
   - **LinkedIn:** [jgaragorry](https://www.linkedin.com/in/jgaragorry)
   - **GitHub Issues:** [iac-immutable-deployment](https://github.com/jgaragorry/iac-immutable-deployment-vagrant-ansible/issues)
   - **WhatsApp:** [+56 956744034](https://wa.me/56956744034)

---

## 📋 Checklists

### Pre-Deployment Checklist

- [ ] All prerequisites installed (`wsl --version`, `docker --version`, etc.)
- [ ] Docker Desktop running on Windows
- [ ] WSL environment variables set (`VAGRANT_WSL_ENABLE_WINDOWS_ACCESS`)
- [ ] Repository cloned
- [ ] Script permissions set (`chmod +x scripts/*.sh`)
- [ ] Ansible syntax validated (`ansible-playbook playbook.yml --syntax-check`)

### Post-Deployment Checklist

- [ ] `vagrant status` shows "running"
- [ ] `docker ps` shows container
- [ ] SSH connection works (`vagrant ssh` succeeds)
- [ ] Ansible playbook completes without errors
- [ ] Services running inside container (`docker ps` inside container)
- [ ] Application accessible (`curl http://localhost:80`)
- [ ] Smoke tests pass (`./scripts/smoke-test.sh`)

### Disaster Recovery Checklist

- [ ] Backed up current `.vagrant/` state
- [ ] Documented any manual changes to infrastructure
- [ ] Ran cleanup scripts before full reset
- [ ] Docker Desktop restarted after recovery
- [ ] Re-deployed and verified all services
- [ ] Checked logs for any errors

---

## 📚 Additional Resources

- [Vagrant Docker Provider Docs](https://www.vagrantup.com/docs/providers/docker)
- [Ansible Playbook Best Practices](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_best_practices.html)
- [Docker Documentation](https://docs.docker.com/)
- [WSL 2 User Guide](https://learn.microsoft.com/en-us/windows/wsl/)
- [SRE Best Practices](https://sre.google/books/)

---

## 📄 Document Versions

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | April 2026 | Juan García Gorry | Complete rewrite with better structure, troubleshooting |
| 1.0 | 2025 | Juan García Gorry | Initial version |

---

**Last Updated:** April 2026 | **Status:** Active ✅ | **Reviewed By:** SRE Team


