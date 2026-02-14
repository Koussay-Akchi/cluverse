# Kubernetes Cluster Setup with Ansible

This Ansible playbook automates the setup of a Kubernetes cluster on OpenStack Epoxy 2025 instances running Ubuntu Noble.

## Prerequisites

- OpenStack Epoxy 2025 instances with Ubuntu Noble image
- SSH access to all instances
- SSH keys configured for passwordless authentication
- Python 3 installed on control and managed nodes
- Ansible 2.9+ installed on the control node

## Configuration

### 1. Update Inventory

Edit `inventory.ini` and add your instance details:

```ini
[masters]
master1 ansible_host=<master_ip>

[workers]
worker1 ansible_host=<worker1_ip>
worker2 ansible_host=<worker2_ip>

[k8s_cluster:children]
masters
workers
```

### 2. Network Configuration

Update `group_vars/all.yml` if needed:
- `kubernetes_version`: Kubernetes version (default: 1.35)
- `pod_network_cidr`: Pod network CIDR (default: 10.244.0.0/16 for Flannel)
- `ansible_user`: SSH user (default: ubuntu)
- `ansible_ssh_private_key_file`: Path to SSH private key

## Deployment Steps

Run the playbooks in order:

```bash
# Step 1: Common setup (disable swap, load modules, configure sysctl)
ansible-playbook 01-common.yml

# Step 2: Install containerd
ansible-playbook 02-containerd.yml

# Step 3: Install Kubernetes
ansible-playbook 03-kubernetes.yml

# Step 4: Initialize master node
ansible-playbook 04-masters.yml

# Step 5: Join worker nodes
ansible-playbook 05-workers.yml

# Step 6: Verify cluster
ansible-playbook 06-verify.yml
```

Or run all at once:

```bash
ansible-playbook 01-common.yml 02-containerd.yml 03-kubernetes.yml 04-masters.yml 05-workers.yml 06-verify.yml
```

## Features

- **Kubernetes v1.35**: Latest stable version
- **containerd**: Modern container runtime with systemd cgroup driver
- **Flannel CNI**: Pod networking solution
- **Ubuntu Noble**: Latest LTS support
- **No Additional Config Required**: All variables pre-configured
- **OpenStack Epoxy 2025**: Compatible with latest OpenStack instances

## Verification

After deployment, verify the cluster:

```bash
# SSH to master node
ssh ubuntu@<master_ip>

# Check nodes
kubectl get nodes -o wide

# Check pods
kubectl get pods --all-namespaces

# Check cluster status
kubectl cluster-info
```

## Troubleshooting

### Nodes not ready
- Check kubelet logs: `journalctl -u kubelet -n 50`
- Check containerd: `systemctl status containerd`
- Verify network connectivity between nodes

### Pod network not working
- Check Flannel pods: `kubectl get pods -n kube-flannel`
- Verify pod CIDR: `kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'`

### Master initialization failed
- Check kubeadm logs: `journalctl -u kubelet --no-pager | tail -50`
- Verify disk space: `df -h`
- Verify swap is disabled: `free -h`

## Network Requirements

- Ensure security groups allow:
  - TCP 6443 (API Server)
  - TCP 2379-2380 (etcd)
  - TCP 10250 (kubelet)
  - TCP 10251-10252 (scheduler, controller-manager)
  - TCP 30000-32767 (NodePort services)
  - UDP 8472 (Flannel VXLAN)

## Clean Up

To reset the cluster:

```bash
ansible-all-hosts "kubeadm reset --force"
ansible-playbook 01-common.yml --tags=reset
```
