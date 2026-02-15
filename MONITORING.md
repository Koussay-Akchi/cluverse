# Kubernetes Monitoring Stack - Prometheus, Alertmanager & Grafana

This Ansible project deploys a complete monitoring solution for Kubernetes 1.35 on Ubuntu Noble with Prometheus, Alertmanager (with email notifications), and Grafana.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Kubernetes Cluster                    │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌────────────────┐  ┌──────────────┐  ┌─────────────┐  │
│  │  Prometheus    │  │ Alertmanager │  │   Grafana   │  │
│  │  (Metrics)     │  │  (Alerting)  │  │(Visualization)│ │
│  └────────────────┘  └──────────────┘  └─────────────┘  │
│         ▲                    ▲                 ▲          │
│         │                    │                 │          │
│  ┌──────┴────────┬───────────┴───────┬────────┴─────┐   │
│  │               │                   │              │   │
│  │ ┌─────────────────┐  ┌───────────────────┐  ┌────┐   │
│  │ │ Node-Exporter   │  │ Kube-State-       │  │ API│   │
│  │ │ (Host Metrics)  │  │ Metrics (K8s)     │  │    │   │
│  │ └─────────────────┘  └───────────────────┘  └────┘   │
│  │  (on all nodes)      (on master)                      │
│  └──────────────────────────────────────────────────────┘
│                                                           │
└─────────────────────────────────────────────────────────┘
                         │
                         │ Email
                         ▼
           SMTP Server (Gmail/Outlook/etc)
```

## Playbooks Overview

### 01-common.yml
System preparation and prerequisites configuration.

### 02-containerd.yml
Container runtime installation and configuration with systemd cgroup driver.

### 03-kubernetes.yml
Kubernetes 1.35.1 components installation (kubelet, kubeadm, kubectl).

### 04-masters.yml
Kubernetes master node initialization and cluster bootstrap with Flannel CNI.

### 05-workers.yml
Worker node deployment and cluster joining.

### 06-verify.yml
Cluster readiness and functionality verification.

### 07-prometheus.yml
**Prometheus Installation & Configuration**
- Deploys Prometheus v2.x in the `prometheus` namespace
- Collects metrics from:
  - Kubernetes API servers
  - Kubernetes nodes
  - Kubernetes pods
  - Kube-State-Metrics
  - Node exporters
- Evaluates alert rules every 15 seconds
- Storage: 15 days retention (configurable)
- ConfigMap-based configuration

### 08-alertmanager.yml
**Alertmanager + Exporters Installation**
- Deploys Alertmanager for alert aggregation and routing
- Node-Exporter DaemonSet on all nodes (hardware metrics)
- Kube-State-Metrics Deployment (Kubernetes object metrics)
- Email notification support with SMTP configuration
- Alert inhibition rules (suppress lower severity when critical fires)
- Alert grouping and deduplication

**Key Alert Rules Include:**
- Node not ready (5m threshold)
- Memory/Disk pressure on nodes
- Pod crash looping detection
- Pod stuck in non-running state (15m threshold)
- Container OOMKilled
- Prometheus config reload failures
- PersistentVolumeClaim pending

### 09-grafana.yml
**Grafana Installation & Dashboards**
- Grafana v10.x with pre-configured Prometheus datasource
- Kubernetes Cluster Overview dashboard with:
  - Node status monitoring
  - CPU usage trends
  - Memory usage trends
  - Network I/O metrics
  - Pod status distribution
  - HTTP request rates
  - Prometheus storage utilization
- NodePort service for external access
- Admin credentials: admin/admin (change in production!)

## Deployment Steps

### Prerequisites Setup

1. **Inventory Configuration** (`inventory.ini`):
```ini
[masters]
master-node-ip

[workers]
worker1-ip
worker2-ip
worker3-ip

[all:children]
masters
workers
```

2. **SMTP Configuration** - Edit `group_vars/monitoring.yml`:

For Gmail:
```yaml
alertmanager_smtp_server: "smtp.gmail.com:587"
alertmanager_smtp_from: "alerts@example.com"
alertmanager_smtp_to: "admin@example.com"
alertmanager_smtp_username: "your-email@gmail.com"
alertmanager_smtp_password: "your-app-specific-password"
```

**Gmail App Password Steps:**
1. Enable 2-Factor Authentication
2. Go to myaccount.google.com → Security
3. Find "App passwords" section
4. Create app password for Mail on Windows
5. Use this password in the configuration

For Office 365/Outlook:
```yaml
alertmanager_smtp_server: "smtp.office365.com:587"
alertmanager_smtp_from: "alerts@example.com"
alertmanager_smtp_to: "admin@example.com"
alertmanager_smtp_username: "your-email@outlook.com"
alertmanager_smtp_password: "your-password"
```

### Deployment Process

```bash
# 1. System preparation on all nodes
ansible-playbook -i inventory.ini 01-common.yml

# 2. Install container runtime (containerd)
ansible-playbook -i inventory.ini 02-containerd.yml

# 3. Install Kubernetes components
ansible-playbook -i inventory.ini 03-kubernetes.yml

# 4. Initialize kubernetes master
ansible-playbook -i inventory.ini 04-masters.yml

# 5. Join worker nodes
ansible-playbook -i inventory.ini 05-workers.yml

# 6. Verify cluster is ready
ansible-playbook -i inventory.ini 06-verify.yml

# 7. Deploy Prometheus monitoring
ansible-playbook -i inventory.ini 07-prometheus.yml

# 8. Deploy Alertmanager and metric exporters
ansible-playbook -i inventory.ini 08-alertmanager.yml

# 9. Deploy Grafana dashboards
ansible-playbook -i inventory.ini 09-grafana.yml
```

## Access Points

### Prometheus
- Internal URL: `http://prometheus.prometheus.svc.cluster.local:9090`
- Check Configuration: `http://prometheus:9090/config`
- View Targets: `http://prometheus:9090/targets`
- Query Interface: `http://prometheus:9090/graph`

### Alertmanager
- Internal URL: `http://alertmanager.prometheus.svc.cluster.local:9093`
- Alerts Dashboard: `http://alertmanager:9093/#/alerts`
- API: `http://alertmanager:9093/api/v1/alerts`

### Grafana
- External Access: `http://<MASTER_NODE_IP>:<GRAFANA_NODEPORT>`
- Default Login: `admin / admin`
- Datasources: Settings → Data Sources → Prometheus (pre-configured)
- Dashboards: Dashboards → Browse → Kubernetes Cluster Overview

### Port Forwarding (if needed)
```bash
# Prometheus
kubectl port-forward -n prometheus service/prometheus 9090:9090

# Alertmanager
kubectl port-forward -n prometheus service/alertmanager 9093:9093

# Grafana
kubectl port-forward -n prometheus service/grafana 3000:3000
```

## Monitoring Verification

### Check Prometheus Target Status
```bash
# SSH to master node
sudo kubectl get pods -n prometheus
sudo kubectl logs -n prometheus deployment/prometheus
sudo kubectl get svc -n prometheus
```

### Send Test Alert
```bash
# Create a test alert manually
kubectl exec -it -n prometheus deployment/alertmanager -- \
  curl -X POST http://localhost:9093/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '[{
    "labels": {
      "alertname": "TestAlert",
      "severity": "warning"
    },
    "annotations": {
      "summary": "Test alert from Kubernetes",
      "description": "This is a test email notification"
    }
  }]'
```

### Verify Email Configuration
```bash
# Check Alertmanager logs for email sending
kubectl logs -n prometheus deployment/alertmanager | grep -i "email\|smtp"
```

## Alert Rules Customization

Edit `/etc/prometheus/rules.yml` in 07-prometheus.yml to add custom alerts:

```yaml
- alert: CustomAlert
  expr: your_metric > threshold
  for: 5m
  labels:
    severity: warning
    team: platform
  annotations:
    summary: "Custom alert triggered"
    description: "Details: {{ $value }}"
```

Reload Prometheus to apply changes:
```bash
kubectl exec -n prometheus deployment/prometheus -- \
  curl -X POST http://localhost:9090/-/reload
```

## Security Considerations

**Production Recommendations:**
1. Change default Grafana password (`admin/admin`)
2. Use secrets for SMTP credentials:
```yaml
# Create Kubernetes secret
kubectl create secret generic alertmanager-smtp \
  --from-literal=password-file=/path/to/password \
  -n prometheus
```

3. Enable TLS/HTTPS for Grafana access
4. Restrict network access via NetworkPolicies
5. Rotate SMTP app passwords regularly
6. Set up RBAC for all service accounts

## Troubleshooting

### Email Not Being Sent
```bash
# Check Alertmanager logs
kubectl logs -n prometheus deployment/alertmanager -f

# Verify configuration
kubectl get configmap -n prometheus alertmanager-config -o yaml
```

### Prometheus Not Scraping Metrics
```bash
# View targets status
kubectl exec -n prometheus pod/prometheus-<pod-id> -- \
  curl -s http://localhost:9090/api/v1/targets | jq

# Check specific target
kubectl logs -n prometheus deployment/prometheus | tail -20
```

### Grafana Dashboard Empty
```bash
# Verify datasource connection
kubectl exec -n prometheus pod/grafana-<pod-id> -- \
  curl -s http://prometheus:9090/api/v1/query?query=up
```

## Scaling & Performance

- **Prometheus Storage**: Adjust retention via `--storage.tsdb.retention.time` flag
- **Scrape Interval**: Default 15s, can be tuned in prometheus.yml global section
- **High Availability**: Deploy multiple Prometheus instances with remote storage
- **Long-term Storage**: Integrate with Prometheus remote storage backends

## Additional Monitored Metrics

- CPU usage, memory, disk I/O per node
- Network traffic (RX/TX)
- Kubernetes API latency
- Etcd health and performance
- Pod restart counts
- Persistent volume usage
- Kubelet metrics

## Version Information

- Kubernetes: 1.35.1
- Prometheus: latest (2.x)
- Alertmanager: latest
- Grafana: latest (10.x)
- Node Exporter: latest
- Kube-State-Metrics: 2.12.0
- Flannel CNI: 0.28.1

## Support & Troubleshooting

For issues or questions:
1. Check component logs: `kubectl logs -n prometheus -l app=<component>`
2. Verify service connectivity: `kubectl describe service -n prometheus`
3. Test alert rules: `kubectl exec -n prometheus pod/prometheus -- promtool check rules`
4. Validate configuration: `kubectl exec -n prometheus pod/alertmanager -- amtool check-config`

## References

- Prometheus Documentation: https://prometheus.io/docs/
- Alertmanager Configuration: https://prometheus.io/docs/alerting/configuration/
- Grafana Documentation: https://grafana.com/docs/grafana/
- Kubernetes Monitoring: https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/
