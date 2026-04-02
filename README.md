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

```markdown
## 🏛️ Architecture at a Glance

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#4CAF50',
  'primaryBorderColor': '#2E7D32',
  'secondaryColor': '#2196F3',
  'secondaryBorderColor': '#0D47A1',
  'tertiaryColor': '#9C27B0',
  'tertiaryBorderColor': '#4A148C',
  'lineColor': '#FF9800',
  'fontSize': '14px',
  'fontFamily': 'system-ui'
}}}%%

flowchart TB
    subgraph INPUT["📥 INPUT LAYER"]
        direction LR
        A["📄 <b>Vagrantfile</b><br/>Infrastructure Definition"]
        B["📝 <b>playbook.yml</b><br/>Configuration State"]
    end
    
    subgraph PROCESS["⚙️ PROCESSING LAYER"]
        direction TB
        C["🔨 <b>Vagrant</b><br/>Provider: Docker"]
        D["🤖 <b>Ansible</b><br/>SSH Transport"]
        E["🐳 <b>Docker CLI</b><br/>Container Runtime"]
    end
    
    subgraph OUTPUT["📤 OUTPUT LAYER"]
        direction TB
        F["🗄️ <b>Base Container</b><br/>Ubuntu 22.04"]
        G["🌐 <b>Nginx Server</b><br/>Port 80 → 8081"]
        H["✅ <b>Deployed App</b><br/>Ready to Serve"]
    end
    
    A --> C
    B --> D
    C --> F
    D -->|🔌 SSH:2200| F
    F --> E
    E --> G
    G --> H
    
    style INPUT fill:#1a1a2e,stroke:#4CAF50,stroke-width:2px,color:#fff
    style PROCESS fill:#0f3460,stroke:#2196F3,stroke-width:2px,color:#fff
    style OUTPUT fill:#2a1a3e,stroke:#9C27B0,stroke-width:2px,color:#fff

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


