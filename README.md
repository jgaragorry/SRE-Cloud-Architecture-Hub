# 🏗️ Infrastructure as Code: Immutable Deployment Pipeline

[![GitHub last commit](https://img.shields.io/github/last-commit/jgaragorry/iac-immutable-deployment-vagrant-ansible)](https://github.com/jgaragorry/iac-immutable-deployment-vagrant-ansible)
[![Infrastructure as Code](https://img.shields.io/badge/IaC-Immutable-4CAF50)](https://en.wikipedia.org/wiki/Infrastructure_as_code)
[![Vagrant](https://img.shields.io/badge/Vagrant-Docker%20Provider-1563FF)](https://www.vagrantup.com)
[![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000)](https://www.ansible.com)
[![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED)](https://www.docker.com)
[![WSL](https://img.shields.io/badge/WSL-Windows%20Subsystem-0078D4)](https://learn.microsoft.com/en-us/windows/wsl/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📋 Descripción General
Este repositorio implementa una **pipeline de despliegue inmutable** diseñada bajo principios de SRE. Utiliza un stack de **Infrastructure as Code (IaC)** para orquestar entornos reproducibles mediante **Vagrant** y **Ansible**, ejecutándose sobre **WSL 2**. 

El proyecto resuelve el desafío de configurar servicios consistentes en entornos híbridos, garantizando que la infraestructura se comporte exactamente igual en desarrollo que en producción.

### 🎯 Valor Estratégico (SRE Insights)
| Característica | Impacto Técnico |
| :--- | :--- |
| **Inmutabilidad** | Eliminación del "Configuration Drift" mediante despliegues desde cero. |
| **Orquestación Híbrida** | Integración nativa de WSL 2 con Docker Desktop Windows. |
| **Idempotencia** | Playbooks de Ansible diseñados para múltiples ejecuciones sin efectos colaterales. |
| **Zero-Trust Auth** | Gestión controlada de claves SSH y validación de hosts en entornos locales. |

---

## 🏛️ Arquitectura de Sistema

'''mermaid
flowchart TD
    subgraph Host [Windows 11 + WSL 2]
        A[WSL Terminal]
        B[Docker Desktop Engine]
    end

    subgraph Orchestration [Capa de Control]
        C(Vagrant: Docker Provider)
        D(Ansible: Provisioner)
    end

    subgraph Targets [Nodos de Infraestructura]
        subgraph Node1 [Ubuntu Container]
            E[SSH Server]
            F[Internal Docker]
            G(App: Nginx Alpine)
        end
    end

    A -->|CLI| C
    C -->|Provision| B
    B -->|Spin up| Node1
    D -->|Config| E
    E -->|Exec| F
    F -->|Run| G

    %% Estilos Profesionales
    classDef control fill:#1a3a5c,stroke:#fff,color:#fff
    classDef tech fill:#1a472a,stroke:#fff,color:#fff
    classDef alert fill:#7a2828,stroke:#fff,color:#fff

    class A,C,D control
    class B,E,F,G tech
'''

---

## 🚀 Quick Start (Fast-Track)

'''bash
# 1. Clonar el repositorio
git clone https://github.com/jgaragorry/iac-immutable-deployment-vagrant-ansible.git
cd iac-immutable-deployment-vagrant-ansible

# 2. Configurar Interoperabilidad WSL 2
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Windows/System32"

# 3. Despliegue Automatizado
vagrant up --provider=docker

# 4. Aprovisionamiento (Comando de Oro)
ansible-playbook -i "127.0.0.1:2200," playbook.yml -u root
'''

---

## 📁 Estructura del Proyecto
'''text
.
├── Vagrantfile                 # Definición de recursos de infraestructura
├── playbook.yml                # Configuración declarativa (Ansible)
├── runbook.md                  # Manual operativo y Troubleshooting
├── Makefile                    # Atajos de automatización (Ops)
└── scripts/
    └── smoke-test.sh           # Scripts de validación post-despliegue
'''

---

## 🔧 Comandos de Operación (Makefile)
| Comando | Acción |
| :--- | :--- |
| `make deploy` | Ejecuta el flujo completo (Up + Provision). |
| `make reset` | Destrucción total y purga de recursos huérfanos. |
| `make verify` | Ejecuta Smoke Tests de conectividad y servicios. |
| `make lint` | Valida la sintaxis de los archivos YAML y Vagrant. |

---

## 🎓 Competencias Demostradas
* **Infrastructure as Code:** Manejo avanzado de proveedores Docker en Vagrant.
* **Configuration Management:** Estructuración de tareas idempotentes en Ansible.
* **Cloud Native Development:** Implementación de Docker-in-Docker (DinD).
* **SRE Documentation:** Creación de Runbooks técnicos para recuperación de desastres.

---

## 📩 Contacto & Redes
| Canal | Enlace |
| :--- | :--- |
| **LinkedIn** | [jgaragorry](https://www.linkedin.com/in/jgaragorry) |
| **GitHub** | [jgaragorry](https://github.com/jgaragorry/) |
| **WhatsApp** | [+56 956744034](https://wa.me/56956744034) |
| **Página Web** | [geekmonkeytech.com](https://geekmonkeytech.com/) |
