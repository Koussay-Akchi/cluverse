# Cluverse — Cloud-Native AI-Centric Club Management Platform

> **ESPRIT PI Project** — Built from the ground up by **Hexateam**.  
> An enterprise-grade, microservice-based, AI-powered SaaS platform designed to modernize student club operations, replace manual spreadsheets and scattered communication, and provide an all-in-one management suite backed by private cloud infrastructure and autonomous AI intelligence.

---

## Gallery

<table>
  <tr>
    <td width="50%" align="center">
      <img src="docs/images/screenshot-1.png" alt="Platform Dashboard" width="100%"/>
      <br/><sub><b>Figure 1:</b> Cluverse Executive Dashboard & Analytics</sub>
    </td>
    <td width="50%" align="center">
      <img src="docs/images/screenshot-2.png" alt="Microservices Topology" width="100%"/>
      <br/><sub><b>Figure 2:</b> OpenStack & Kubernetes Infrastructure Topology</sub>
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
      <img src="docs/images/screenshot-3.png" alt="AI Speech Analyzer" width="100%"/>
      <br/><sub><b>Figure 3:</b> AI Interview & Speech Analyzer (Whisper v2 + Groq)</sub>
    </td>
    <td width="50%" align="center">
      <img src="docs/images/screenshot-4.png" alt="Prophet Predictive Monitoring" width="100%"/>
      <br/><sub><b>Figure 4:</b> Predictive Monitoring with Meta Prophet & Grafana</sub>
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
      <img src="docs/images/screenshot-5.png" alt="Sponsorship & Finance Module" width="100%"/>
      <br/><sub><b>Figure 5:</b> Sponsorship Outreach, Dynamic Contracts & Stripe Payments</sub>
    </td>
    <td width="50%" align="center">
      <img src="docs/images/screenshot-6.png" alt="Alertmanager & Observability" width="100%"/>
      <br/><sub><b>Figure 6:</b> Real-time Alertmanager Notifications & Anomaly Detection</sub>
    </td>
  </tr>
</table>

---

## Vision & Problem Statement

University clubs and student organizations operate like micro-enterprises: they manage five-figure budgets, coordinate hundreds of members, organize flagship multi-day hackathons, run democratic elections, and secure corporate sponsorships. Yet almost all rely on fragmented tools — chaotic Excel spreadsheets, unstructured WhatsApp groups, manual paper contracts, and unstandardized interviews.

**Cluverse** solves this by delivering an integrated, self-healing, multi-tenant SaaS ecosystem where intelligence is built directly into every operational module.

---

## Key Highlights & Architecture Pillars

### 1. Private Cloud Infrastructure & Orchestration
* **OpenStack Heat (`heat.yaml`)**: Automated provisioning of private virtual networks, subnets, routers, floating IPs, and compute instances across dedicated master, worker, and monitoring nodes.
* **Kubernetes Cluster (v1.35.1)**: Bootstrapped with `kubeadm` and `containerd`, orchestrating pods across master and worker pools with Horizontal Pod Autoscaling (HPA) and zero-downtime rolling updates.
* **Ingress & Secure Networking**: Unified traffic routing via **Spring Cloud Gateway**, Ingress-NGINX controllers, automated SSL/TLS certificates via **Cert-Manager (Let's Encrypt ACME)**, and global tunneling via **Cloudflare Tunnel (`cloudflared`)**.
* **Automated CI/CD & Configuration Management**: End-to-end automation with **Ansible playbooks**, automated image polling daemon for zero-downtime container updates, and GitHub Actions integration.

### 2. Multi-Layer Observability & Predictive AI Monitoring
* **Prometheus & Node Exporter**: Scrapes Kubernetes nodes, cluster daemons, and Spring Boot Actuator endpoints every 15s.
* **Alertmanager**: Tiered routing for `critical` and `warning` incidents with automated HTML email dispatch via SMTP.
* **Grafana Dashboards**: Live visualizations for cluster health, pod resource saturation, HTTP request latency, and service status.
* **AI Predictive Anomaly Detection (Meta Prophet)**: Embedded Flask + Prophet time-series engine predicting CPU, memory, and traffic spikes ahead of time based on historical telemetry.
* **Zabbix Integration**: Complementary enterprise host monitoring tracking hardware metrics, OS thresholds, and network connectivity.

### 3. Integrated Microservices Architecture
* **`eureka-server`**: Spring Cloud Netflix Eureka service registry enabling dynamic service discovery and heartbeat health checks.
* **`api-gateway`**: High-performance gateway handling routing, CORS policies, centralized authentication, and rate limiting.
* **`User-Cluverse`**: Account lifecycle management, role-based access control (RBAC), JWT authentication, and OAuth2 integration (Google & GitHub).
* **`Competencies-Cluverse`**: Member skill profiles, competency evaluation sessions, and peer feedback tracking.
* **`Elections-Cluverse`**: Democratic election workflows, candidate registration, term limits, and cryptographic weighted voting.
* **`Events-Cluverse`**: Event publishing, ticketing, automated waiting list management, and attendee check-ins.
* **`Finance-Cluverse`**: Club and event budget tracking, categorized expense/income ledger, and Stripe donation processing.
* **`Logistics-Cluverse`**: Shared inventory management, vehicle fleet tracking, fuel consumption logs, and maintenance alerts.
* **`Sponsors-Cluverse`**: Multi-stage sponsorship CRM, automated tokenized email responses, dynamic PDF contract generation, and payment portals.
* **`Frontend-Cluverse`**: Responsive single-page application built with Angular 18.

### 4. Applied AI Services
* **Candidate Speech & Interview Analyzer (`speech-analyzer`)**: FastAPI service utilizing OpenAI Whisper v2 and Groq Llama 3.1 to transcribe interview audio, compute words-per-minute (WPM), and provide objective scoring metrics without human bias.
* **AI Bio Generator (`BioGenerator`)**: Generates tailored candidate and member descriptions highlighting club accomplishments and background.
* **Cashflow Forecasting Service (`cashflow-forecast-service`)**: Time-series predictive model forecasting treasury balances, cashflow dips, and budget risks before deficits occur.
* **Stripe Fraud Detection (`stripe-fraud-ai-detection-system`)**: Anomaly detection model screening incoming transactions for fraudulent payment characteristics.

---

## Tech Stack

| Domain | Technologies |
| :--- | :--- |
| **Backend Microservices** | Java 17, Spring Boot 3.4, Spring Cloud Gateway, Spring Cloud Eureka, Spring Data JPA |
| **AI / Machine Learning** | Python 3.11, FastAPI, Meta Prophet, PyTorch 2.9, Whisper v2, Groq API (Llama 3.1) |
| **Frontend** | Angular 18, TypeScript, RxJS, TailwindCSS, Chart.js |
| **Database & Caching** | MySQL 8, Redis |
| **Cloud & Virtualization** | OpenStack (Heat Orchestration), Microsoft Azure, Linux Ubuntu (22.04 / 24.04) |
| **Containers & Orchestration** | Docker, containerd, Kubernetes (1.35.1), Helm, Kubeadm, MetalLB |
| **Ingress & Security** | Ingress-NGINX, Cloudflare Tunnel (`cloudflared`), Cert-Manager (Let's Encrypt), OAuth2, JWT |
| **IaC & Automation** | Ansible, Terraform, Bash, GitHub Actions |
| **Monitoring & Logging** | Prometheus, Alertmanager, Grafana, Meta Prophet AI Predictor, Zabbix |
| **External Integrations** | Stripe API, Google OAuth2, GitHub OAuth2, Gmail SMTP, Twilio, Meta API |

---

## Repository & Playbook Structure

```
ansible/
├── ansible.cfg                  # Ansible configuration and inventory plugin setup
├── openstack.yaml               # Dynamic inventory targeting OpenStack instances
├── heat.yaml                    # OpenStack Heat Orchestration template
├── yalla.sh                     # Master orchestration script (stack teardown, deploy, playbook execution)
├── group_vars/
│   ├── all.yml                  # Global cluster variables (k8s version, CIDR, IPs)
│   └── monitoring.yml           # Monitoring parameters (alert emails, retention, scrape intervals)
├── k8s/                         # Kubernetes manifests
│   ├── secrets.yml.example      # Sanitized template for application secrets
│   ├── configmap.yml            # Cluster-wide microservice configuration
│   ├── ingress-proxy.yml        # Ingress routing rules
│   ├── cloudflare-tunnel.yml    # Cloudflare Tunnel deployment manifest
│   ├── cluster-issuer.yml       # Cert-manager Let's Encrypt issuer
│   └── *.yml                    # Manifests for all individual Cluverse services
├── playbooks/
│   ├── site.yml                 # Master playbook orchestrating complete cluster rollout
│   ├── 01-common.yml            # System dependencies, kernel modules, firewall rules
│   ├── 02-containerd.yml        # Container runtime installation & cgroup driver setup
│   ├── 03-kubernetes.yml        # Kubeadm, kubelet, kubectl installation
│   ├── 04-masters.yml           # Control-plane initialization & networking (Flannel/Calico)
│   ├── 05-workers.yml           # Worker node join procedure
│   ├── 06-verify.yml            # Cluster health validation
│   ├── 07-prometheus.yml        # Prometheus server & RBAC deployment
│   ├── 08-alertmanager.yml      # Alertmanager alerting rules & email notifications
│   ├── 09-grafana.yml           # Grafana visualization & datasource provisioning
│   ├── 10-ai.yml                # Meta Prophet predictive monitoring engine
│   ├── 11-cluverse-infra.yml    # MySQL, Ingress, Cert-Manager, and secrets deployment
│   ├── 12-cluverse-services.yml # Deployment of all Cluverse microservices
│   ├── 13-ngrok.yml             # External developer tunnel (optional)
│   ├── 14-cluster-health-lb.yml # Healthcheck load balancer
│   ├── 15-image-autoupdate.yml  # Daemon for automated Docker Hub image updates
│   ├── 16-cert-manager.yml      # Cert-Manager installation
│   └── 17-cloudflare-tunnel.yml # Cloudflare tunnel configuration
└── roles/                       # Modular reusable Ansible roles
    ├── hexaweb/                 # Infrastructure & application roles
    └── monitoring/              # Observability & AI predictor roles
```

---

## Deployment Guide

### 1. Prerequisites
* OpenStack CLI configured with `clouds.yaml` credentials.
* Control machine with Python 3, `ansible-core` (>= 2.15), and `openstacksdk`.
* SSH key pair deployed to OpenStack (default: `mykey` pointing to `/root/.ssh/id_ed25519`).

### 2. Configure Credentials
Copy the secret template and populate real environment credentials:
```bash
cp k8s/secrets.yml.example k8s/secrets.yml
```
Update `group_vars/all.yml` and `group_vars/monitoring.yml` with your SMTP alert credentials, Grafana admin password, and authentication tokens.

### 3. One-Click Automated Deployment
Run the automated deployment script:
```bash
chmod +x yalla.sh
./yalla.sh
```

`yalla.sh` performs the following automated phases:
1. Validates and recreates the OpenStack Heat stack (`heat.yaml`).
2. Clears stale SSH host keys and verifies SSH connectivity across all provisioned nodes.
3. Executes `playbooks/site.yml` to install runtimes, bootstrap Kubernetes, apply manifests, and start the monitoring stack.

### 4. Running Individual Playbooks
To run or re-apply specific stages manually:
```bash
# Bootstrap Kubernetes cluster
ansible-playbook playbooks/01-common.yml
ansible-playbook playbooks/02-containerd.yml
ansible-playbook playbooks/03-kubernetes.yml
ansible-playbook playbooks/04-masters.yml
ansible-playbook playbooks/05-workers.yml

# Deploy monitoring & AI forecasting
ansible-playbook playbooks/07-prometheus.yml
ansible-playbook playbooks/08-alertmanager.yml
ansible-playbook playbooks/09-grafana.yml
ansible-playbook playbooks/10-ai.yml

# Deploy Cluverse application stack
ansible-playbook playbooks/11-cluverse-infra.yml
ansible-playbook playbooks/12-cluverse-services.yml
```

---

## The Team — Hexateam

This project was engineered and delivered as part of the **ESPRIT PI Project** by **Hexateam**:

* **[Khamlia Feriel](https://www.linkedin.com/in/khamlia-feriel-905667212/)**
* **[Ibtissem Ben Amara](https://www.linkedin.com/in/ibtissem-ben-amara/en/)**
* **[Koussay Akchi](https://www.linkedin.com/in/koussay-akchi/)**
* **[Amine Mokhtar](https://www.linkedin.com/in/amine-mokhtar-679038277/)**
* **[Louay Tlili](https://www.linkedin.com/in/louay-tlili-799228287/)**
* **[Jihen Ghabi](https://www.linkedin.com/in/jihen-ghabi-/)**
* **[Louay Zorai](https://www.linkedin.com/in/louay-zorai-aa5583262/)**

Special thanks to our coaches:
* **[Rihem Matoussi](https://www.linkedin.com/in/rihem-matoussi-228b01195/)**
* **[Hiba Ouni](https://www.linkedin.com/in/hiba-ouni-7a639915a/)**
