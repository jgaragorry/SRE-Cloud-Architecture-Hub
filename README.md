# 🏗️ Immutable Infrastructure Deployment Pipeline

> **Infrastructure as Code meets SRE Excellence** — A production-grade deployment pipeline combining Vagrant, Ansible, and Docker on WSL 2

[![GitHub Workflow](https://img.shields.io/badge/Workflow-IaC%20%2B%20Automation-4CAF50?style=flat-square)](https://en.wikipedia.org/wiki/Infrastructure_as_code)
[![Vagrant](https://img.shields.io/badge/Vagrant-2.4.0+-1563FF?style=flat-square&logo=vagrant)](https://www.vagrantup.com)
[![Ansible](https://img.shields.io/badge/Ansible-9.0+-EE0000?style=flat-square&logo=ansible)](https://www.ansible.com)
[![Docker](https://img.shields.io/badge/Docker-24.0+-2496ED?style=flat-square&logo=docker)](https://www.docker.com)
[![WSL 2](https://img.shields.io/badge/WSL-2.0+-0078D4?style=flat-square&logo=windows-terminal)](https://learn.microsoft.com/en-us/windows/wsl/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

---

## 🎯 What This Is

A **battle-tested, immutable infrastructure framework** designed for:
- ✅ **Zero configuration drift** — Everything torn down and rebuilt from scratch
- ✅ **Reproducible deployments** — Identical results, every single time
- ✅ **Native Windows integration** — Vagrant + Docker Desktop + WSL 2 working seamlessly
- ✅ **SRE-grade automation** — Idempotent Ansible playbooks, proper SSH management, zero manual steps
- ✅ **Fast feedback loops** — Deploy and validate in seconds

Perfect for **DevOps engineers, SREs, and infrastructure architects** learning or demonstrating immutable infrastructure practices.

---

## 🏛️ Architecture at a Glance

'''mermaid
flowchart TB
    %% Definición de Nodos con Estética Moderna
    subgraph WindowsHost [💻 Windows 11 Workspace]
        direction TB
        subgraph WSL [🐧 WSL 2 Ubuntu Environment]
            direction LR
            VCLI([Vagrant CLI])
            ACN[[Ansible Control Node]]
        end
        
        DDE{{Docker Desktop Engine}}
    end

    subgraph Infrastructure [☁️ Infrastructure Layer]
        direction TB
        subgraph TargetCont [🐳 Container: Ubuntu 22.04]
            direction TB
            SSH[SSH Server :2200]
            DIND[Docker Engine - DinD]
            APP(Application: Nginx Alpine)
        end
    end

    %% Flujo de Orquestación con Estilo
    VCLI -->|1. Provider Call| DDE
    DDE -->|2. Spin Up| TargetCont
    ACN -->|3. SSH Provision| SSH
    SSH -->|4. Config| DIND
    DIND -->|5. Run| APP

    %% Estilizado Avanzado (Arquitecto de Soluciones)
    classDef control fill:#1a3a5c,stroke:#5fb0ff,stroke-width:2px,color:#fff,font-weight:bold;
    classDef runtime fill:#1a472a,stroke:#7ed321,stroke-width:2px,color:#fff,font-weight:bold;
    classDef engine fill:#2d2d2d,stroke:#999,stroke-width:2px,color:#fff,font-style:italic;
    classDef ghost fill:none,stroke:#333,stroke-width:1px,stroke-dasharray: 5 5,color:#333;

    class VCLI,ACN control;
    class TargetCont,APP,SSH runtime;
    class DDE,DIND engine;
    class WindowsHost,WSL,Infrastructure ghost;

    %% Ajustes de Subgrafos
    style WindowsHost fill:#f0f4f8,stroke:#d1d9e6
    style Infrastructure fill:#f0f4f8,stroke:#d1d9e6
'''

---

## 📋 Quick Start (3 Steps)

### Step 1️⃣ Clone & Navigate
```bash
git clone https://github.com/jgaragorry/iac-immutable-deployment-vagrant-ansible.git
cd iac-immutable-deployment-vagrant-ansible
```

### Step 2️⃣ Enable WSL-Docker Bridge
```bash
# Make WSL aware of Docker Desktop
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Windows/System32"

# Verify Docker responds
docker ps
```

### Step 3️⃣ Deploy (One Command)
```bash
vagrant up --provider=docker
```

**That's it.** Your immutable infrastructure is live.

---

## 🚀 Full Deployment Workflow

### 1️⃣ **Initialize Infrastructure**
```bash
vagrant up --provider=docker
```
- Spins up Ubuntu 22.04 container
- Installs SSH server
- Validates network connectivity

### 2️⃣ **Configure with Ansible** (The "Golden Command")
```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
  -i "127.0.0.1:2200," \
  playbook.yml \
  -u root \
  -e "ansible_password=root" \
  --ssh-extra-args="-o StrictHostKeyChecking=no"
```

**What happens:**
- Docker daemon installed and started inside container
- Nginx Alpine container deployed
- Health checks validated
- Idempotent execution (safe to run 10x)

### 3️⃣ **Verify & Test**
```bash
# SSH into container
vagrant ssh

# Inside container: check Nginx
docker ps
curl http://localhost:80
```

### 4️⃣ **Cleanup (Full Reset)**
```bash
vagrant destroy -f
docker rm -f $(docker ps -aq) 2>/dev/null
docker rmi $(docker images -q) -f 2>/dev/null
```

---

## 📁 Project Structure

```
.
├── Vagrantfile              # Infrastructure definition (Docker provider)
├── playbook.yml             # Ansible configuration (idempotent tasks)
├── RUNBOOK.md              # Operational guide & troubleshooting
├── Makefile                # Convenient command shortcuts
├── README.md               # This file
└── scripts/
    └── smoke-test.sh       # Post-deployment validation
```

---

## 🔧 Common Operations

| Command | What It Does |
|---------|-------------|
| `vagrant up --provider=docker` | Spin up container infrastructure |
| `vagrant ssh` | SSH into running container |
| `vagrant status` | Show container status |
| `vagrant destroy -f` | Tear down infrastructure completely |
| `ansible-playbook -i "127.0.0.1:2200," playbook.yml -u root -e "ansible_password=root"` | Apply configuration management |
| `./scripts/smoke-test.sh` | Run health checks |

**Makefile shortcuts** (if configured):
```bash
make deploy    # vagrant up + ansible provision
make verify    # smoke tests
make reset     # destroy + clean
make lint      # validate YAML syntax
```

---

## 🎓 Key Concepts Demonstrated

### **Immutability**
No "configuration drift" or manual tweaks that vanish on reboot. Everything is reproducible from code.

### **Idempotence**
Ansible playbooks designed to safely run multiple times without side effects. Deploy 10 times, get the same result.

### **Infrastructure as Code**
Every brick of your infrastructure is version-controlled, peer-reviewable, and executable.

### **SRE Practices**
- Zero-trust SSH authentication
- Health checks and smoke tests
- Clear runbooks for incident response
- Reproducible environment for debugging

### **Container-Native Design**
Docker-in-Docker (DinD) running production workloads on an immutable base.

---

## ⚠️ Important Notes

### About Vagrant's `/etc/fstab` Error
When `vagrant up` completes, you may see an error about `sed` and `/etc/fstab`. **This is safe to ignore.**

Vagrant tries to mount filesystems that don't exist in Docker containers. It fails gracefully and doesn't affect functionality.

### SSH Key Management
Ansible uses password authentication (`root:root`) for simplicity in local dev. For production:
- Generate SSH keypairs
- Distribute public keys to infrastructure
- Remove password auth from playbooks

### Network Isolation
The container runs on `127.0.0.1:2200` by default. To expose services:
1. Update `Vagrantfile` with port mappings
2. Rebuild with `vagrant up`

---

## 🔍 Validation Checklist

After deployment, verify:
- [ ] `vagrant status` shows "running"
- [ ] `vagrant ssh` connects without password
- [ ] Inside container: `docker ps` shows running Nginx
- [ ] `curl http://localhost:80` returns Nginx homepage
- [ ] Ansible playbook runs successfully
- [ ] `./scripts/smoke-test.sh` passes all checks

---

## 🛠️ Troubleshooting

### Docker not responding from WSL
```bash
# Ensure Docker Desktop is running
# Check Windows Start Menu → Docker Desktop

# Verify connection
docker ps
```

### Vagrant can't find Docker provider
```bash
# Check Docker is in PATH
which docker

# Reinstall Vagrant
vagrant --version  # Should be 2.4.0+
```

### Ansible SSH timeout to 127.0.0.1:2200
```bash
# Remove stale SSH keys
ssh-keygen -f ~/.ssh/known_hosts -R "[127.0.0.1]:2200"

# Try connection manually
ssh -p 2200 root@127.0.0.1  # password: root
```

### Container won't start
```bash
# Check Docker logs
docker logs <container_id>

# Clean slate
vagrant destroy -f
docker system prune -a
vagrant up --provider=docker
```

---

## 📚 Learning Resources

- **Vagrant Docs:** https://www.vagrantup.com/docs
- **Ansible Best Practices:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_best_practices.html
- **SRE Book:** https://sre.google/books/
- **Docker-in-Docker:** https://www.docker.com/blog/docker-in-docker-composing-multi-container-docker-applications/

---

## 💡 Real-World Applications

This pipeline is ideal for:
- **Lab environments** — Practice infrastructure automation safely
- **CI/CD testing** — Validate infrastructure changes before production
- **Training & demos** — Show immutable infrastructure in action
- **Disaster recovery drills** — Practice rebuilding from scratch
- **Multi-environment promotion** — Dev → Staging → Prod with identical configs

---

## 👨‍💻 About the Author

**Juan García Gorry** — SRE & Infrastructure Architect

| Platform | Link |
|----------|------|
| **LinkedIn** | [jgaragorry](https://www.linkedin.com/in/jgaragorry) |
| **GitHub** | [jgaragorry](https://github.com/jgaragorry/) |
| **WhatsApp** | [+56 956744034](https://wa.me/56956744034) |
| **Website** | [geekmonkeytech.com](https://geekmonkeytech.com/) |

---

## 📄 License

MIT License — Free to use, modify, and distribute.

---

## 🤝 Contributing

Found a bug? Have a better approach? **Pull requests welcome!**

Please ensure:
- Code follows SRE best practices
- Runbooks are updated
- All smoke tests pass

---

**Last Updated:** April 2026 | **Status:** Production-Ready ✅


