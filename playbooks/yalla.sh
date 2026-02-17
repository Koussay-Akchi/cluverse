#!/bin/bash
set -e

STACK_NAME="k8s-cluster"
TEMPLATE="/home/feriel/temp.yaml"
ANSIBLE_PLAYBOOK="/root/k8s-ansible/playbooks/site.yml"

echo -e "\n=== NETTOYAGE CACHE ANSIBLE ==="
rm -rf /tmp/ansible_inventory_cache/
rm -rf ~/.ansible/tmp/*
rm -rf ~/.cache/ansible-compat/*

echo -e "\n=== ATTENTE SSH ==="

# Récupérer UNIQUEMENT les IPs qui commencent par 192
IPS=$(openstack stack output show "$STACK_NAME" --all -f value | grep -Eo '192\.([0-9]{1,3}\.){2}[0-9]{1,3}')

echo "IPs trouvées: $IPS"

# Nettoyer les clés SSH connues
for ip in $IPS; do
    ssh-keygen -R "$ip" 2>/dev/null || true
done

# Attendre SSH
for ip in $IPS; do
  echo "Checking SSH on $ip..."
  until nc -z -w5 "$ip" 22 2>/dev/null; do
    echo "  Waiting..."
    sleep 5
  done
  echo "  ✓ SSH is up on $ip"
done

echo -e "\n=== EXÉCUTION ANSIBLE ==="
ansible-playbook "$ANSIBLE_PLAYBOOK"

echo -e "\n✓ DÉPLOIEMENT TERMINÉ!"
