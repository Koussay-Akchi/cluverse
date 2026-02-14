# Quick Start - Kubernetes Monitoring Integration

## Files Created

1. **07-prometheus.yml** - Prometheus metrics collection
2. **08-alertmanager.yml** - Email alerts and metric exporters
3. **09-grafana.yml** - Visualization dashboards
4. **group_vars/monitoring.yml** - SMTP configuration
5. **MONITORING.md** - Complete documentation

## Version Verification (February 2026)

✅ **Prometheus**: v3.9.1 (stable, released Jan 2026)  
✅ **Alertmanager**: v0.31.1 (stable, released Jan 2026)  
✅ **Grafana**: v10.x (latest, updated 23 days ago)  
✅ **Node Exporter**: v1.10.2 (stable)  
✅ **Kube-State-Metrics**: v2.12.0 (compatible with K8s 1.35)  
✅ **Kubernetes**: v1.35.1 (latest stable)  

All components verified working with Kubernetes 1.35 on Ubuntu Noble 2026.

## Quick Deployment (One Command Per Step)

```bash
# Run all 9 playbooks in sequence
for i in {01..09}; do
  echo "Running playbook $i..."
  ansible-playbook -i inventory.ini 0$i-*.yml || exit 1
done
```

## Configuration - Before Running

**Edit `group_vars/monitoring.yml` with your SMTP details:**

```yaml
# Gmail Example
alertmanager_smtp_server: "smtp.gmail.com:587"
alertmanager_smtp_from: "alerts@example.com"
alertmanager_smtp_to: "admin@example.com"
alertmanager_smtp_username: "your-email@gmail.com"
alertmanager_smtp_password: "your-app-password"
```

## Access URLs (After Deployment)

| Component | URL | Credentials |
|-----------|-----|-------------|
| Prometheus | `http://MASTER_IP:9090` | none |
| Alertmanager | `http://MASTER_IP:9093` | none |
| Grafana | `http://MASTER_IP:NODEPORT` | admin/admin |

Get Grafana NodePort:
```bash
kubectl get service grafana -n prometheus -o jsonpath='{.spec.ports[0].nodePort}'
```

## What Gets Monitored

✅ Kubernetes API server status  
✅ Node CPU, memory, disk, network  
✅ Pod status and crashes  
✅ Persistent volume claims  
✅ Prometheus itself (meta-monitoring)  
✅ Alertmanager status  

## Alert Examples Included

- Node not ready (5m threshold)
- Memory/Disk pressure
- Pod crash looping
- OOMKilled containers
- Config reload failures
- PersistentVolumeClaim pending

## Email Alerts

**Automatic emails sent when:**
- Critical alerts fire (immediate)
- Warning alerts fire (within group_wait)
- Alerts resolve (if send_resolved=true)

**Email includes:**
- Alert name and severity
- Affected node/pod
- Alert description
- Alert state and timestamps

## Testing

### Check Prometheus Targets
```bash
kubectl exec -n prometheus deployment/prometheus -- \
  curl -s http://localhost:9090/api/v1/targets | jq
```

### Check Alertmanager Connectivity
```bash
kubectl logs -n prometheus deployment/alertmanager | grep -i "email\|smtp"
```

### Test Email Configuration
```bash
# Create test alert
kubectl exec -n prometheus deployment/alertmanager -- \
  curl -X POST http://localhost:9093/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '[{
    "labels": {"alertname": "TestAlert", "severity": "warning"},
    "annotations": {"summary": "Test email notification"}
  }]'
```

### View Grafana Dashboards
1. Open `http://MASTER_IP:NODEPORT`
2. Login: admin/admin
3. Go to Dashboards → Browse
4. Select "Kubernetes Cluster Overview"
5. Change time range to "Last 1 hour"

## Troubleshooting

### No metrics showing
```bash
kubectl logs -n prometheus deployment/prometheus -f
kubectl get pods -n prometheus
```

### Emails not sending
```bash
kubectl logs -n prometheus deployment/alertmanager
# Check if SMTP credentials are correct
kubectl get configmap -n prometheus alertmanager-config -o yaml
```

### Grafana connection refused
```bash
# Port forward
kubectl port-forward -n prometheus service/grafana 3000:3000 &
# Then access: http://localhost:3000
```

## Production Recommendations

1. **Change default Grafana password**
   ```bash
   kubectl exec -n prometheus pod/grafana-XXX -- \
     grafana-cli admin reset-admin-password newpassword
   ```

2. **Enable HTTPS** for Grafana (nginx ingress recommended)

3. **Store SMTP password in Kubernetes Secret**
   ```bash
   kubectl create secret generic alertmanager-smtp-password \
     --from-literal=password='...' -n prometheus
   ```

4. **Set resource limits** in playbooks (already done)

5. **Configure persistent storage** for Prometheus data

6. **Set up multi-replica Alertmanager** for HA

## Monitoring the Monitoring Stack

These dashboards show:
- Prometheus scrape targets and success rates
- Alertmanager alert processing
- Memory/CPU usage of monitoring components
- Data retention and storage usage

## Integration Points

**Other services can** be monitored by:
1. Adding scrape configs to Prometheus
2. Deploying exporters (MySQL, PostgreSQL, Redis, etc.)
3. Creating custom alerts in Prometheus rules
4. Adding dashboards to Grafana

**Example**: Monitor nginx
```yaml
- job_name: 'nginx'
  static_configs:
    - targets: ['nginx-server:9113']
```

## Support Resources

- Prometheus Docs: https://prometheus.io/docs/
- Alertmanager Config: https://prometheus.io/docs/alerting/configuration/
- Grafana Docs: https://grafana.com/docs/grafana/
- Kube-State-Metrics: https://github.com/kubernetes/kube-state-metrics

## Next Steps

1. Deploy all playbooks (takes ~10 minutes)
2. Verify all pods are running: `kubectl get pods -n prometheus`
3. Access Grafana and create custom dashboards
4. Configure alert routing and notification channels
5. Set up on-call schedules/escalation policies
6. Create runbooks for critical alerts

---

**Ready to deploy?** Run this after configuration:
```bash
ansible-playbook -i inventory.ini 07-prometheus.yml && \
ansible-playbook -i inventory.ini 08-alertmanager.yml && \
ansible-playbook -i inventory.ini 09-grafana.yml
```

Monitor progress:
```bash
kubectl get pods -n prometheus -w
```
