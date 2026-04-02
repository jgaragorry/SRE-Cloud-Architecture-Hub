# RUNBOOK: Despliegue Inmutable de Infraestructura como Código

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://semver.org)
[![IaC](https://img.shields.io/badge/IaC-Inmutable-orange.svg)](https://www.terraform.io)
[![Vagrant](https://img.shields.io/badge/Vagrant-2.4.0-1563FF.svg)](https://www.vagrantup.com)
[![Ansible](https://img.shields.io/badge/Ansible-9.0-EE0000.svg)](https://www.ansible.com)
[![Docker](https://img.shields.io/badge/Docker-24.0-2496ED.svg)](https://www.docker.com)
[![WSL](https://img.shields.io/badge/WSL-2.0-4D4D4D.svg)](https://learn.microsoft.com/en-us/windows/wsl/)

## 🎯 Objetivo
Este runbook documenta el proceso de despliegue **inmutable** y **reproducible** de una aplicación contenedorizada utilizando Vagrant (provider Docker), Ansible como motor de configuración y Docker como runtime, todo ejecutado desde WSL 2 en Windows.

## 🏗️ Diagrama de Arquitectura

'''mermaid
flowchart TD
    subgraph Local_WSL [Entorno de Control (WSL 2)]
        A[Terminal WSL 2]
        F[Ansible Control Node]
    end

    subgraph Infrastructure [Capa de Infraestructura]
        B(Vagrant Docker Provider)
        C[Container: Ubuntu 22.04]
    end

    subgraph Workload [Capa de Aplicación]
        G[Docker Engine Interno]
        H(Nginx:alpine)
    end

    A -->|vagrant up| B
    B -->|Crea| C
    F -->|SSH Port 2200| C
    F -->|Ejecuta Playbook| C
    C -->|Instala| G
    G -->|Despliega| H
    
    I[Navegador Windows] -->|localhost:8081| H

    %% Estilos de SRE Architect
    classDef process fill:#1a3a5c,stroke:#fff,color:#fff
    classDef success fill:#1a472a,stroke:#fff,color:#fff
    classDef alert fill:#7a2828,stroke:#fff,color:#fff
    
    class A,F,B process
    class C,G success
    class H success
    class I alert
'''

## 📋 Prerrequisitos Técnicos

| Componente | Versión Mínima | Comando de Verificación |
| :--- | :--- | :--- |
| **Windows 10/11** | 22H2 | `winver` |
| **WSL 2** | 2.0.0 | `wsl --version` |
| **Vagrant** | 2.4.0 | `vagrant --version` |
| **Docker Desktop** | 24.0 | `docker --version` |
| **Ansible** | 9.0 | `ansible --version` |

---

## 🚀 Fase 1: Hard Reset (Estado Cero)
⚠️ **ADVERTENCIA:** Este paso elimina TODOS los recursos. Ejecutar solo si se desea un estado completamente limpio.

'''bash
#!/bin/bash
# 1. Limpiar Docker (contenedores e imágenes)
docker rm -f $(docker ps -aq) 2>/dev/null
docker rmi $(docker images -q) -f 2>/dev/null

# 2. Limpiar Vagrant
vagrant destroy -f
rm -rf .vagrant/

# 3. Limpiar memoria de SSH (Fix de seguridad)
ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "[127.0.0.1]:2200" 2>/dev/null
echo "✅ Estado Cero alcanzado - Todos los recursos eliminados"
'''

---

## 🐧 Fase 2: Preparación del Entorno WSL
📌 **Nota:** Estas variables permiten que Vagrant desde WSL se comunique con Docker Desktop en Windows.

'''bash
# Configurar acceso a Docker de Windows
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"

# Verificar que Docker responde
docker ps

# Persistir variables
echo 'export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"' >> ~/.bashrc
'''

---

## 🔧 Fase 3: Despliegue Automático con Vagrant

'''bash
# Iniciar el contenedor base
vagrant up --provider=docker

# Verificar estado
vagrant status
'''

> ℹ️ **Nota de SRE:** Si al final del `up` ves un error de `sed` en `/etc/fstab`, **IGNÓRALO**. Es Vagrant intentando montar sistemas de archivos que no existen en un contenedor Docker.

---

## ⚙️ Fase 4: Orquestación con Ansible (El "Comando de Oro")

'''bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
  -i "127.0.0.1:2200," \
  playbook.yml \
  -u root \
  -e "ansible_password=root" \
  --ssh-extra-args="-o StrictHostKeyChecking=no"
'''

### 📊 Estructura esperada del playbook
'''yaml
---
- name: Configuración inmutable del contenedor
  hosts: all
  gather_facts: yes
  tasks:
    - name: Instalar Docker y dependencias
      apt:
        name:
          - docker.io
          - docker-compose
        state: present
        update_cache: yes

    - name: Iniciar servicio Docker
      systemd:
        name: docker
        state: started
        enabled: yes

    - name: Ejecutar contenedor Nginx
      docker_container:
        name: web_app
        image: nginx:alpine
        ports:
          - "80:80"
        restart_policy: always
'''

---

## ✅ Fase 5: Smoke Test (Validación)

'''bash
# Probar conectividad al contenedor
curl -I http://127.0.0.1:2200 2>/dev/null | head -n 1

# Verificar contenedor corriendo internamente
vagrant ssh -c "docker ps --filter 'name=web_app'"
'''

---

## 📩 Contacto & Redes
| Canal | Enlace |
| :--- | :--- |
| **LinkedIn** | [jgaragorry](https://www.linkedin.com/in/jgaragorry) |
| **GitHub** | [jgaragorry](https://github.com/jgaragorry/) |
| **WhatsApp** | [+56 956744034](https://wa.me/56956744034) |
| **Página Web** | [geekmonkeytech.com](https://geekmonkeytech.com/) |
