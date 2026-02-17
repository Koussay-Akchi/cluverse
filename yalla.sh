#!/bin/bash
set -e
 
STACK_NAME="k8s-cluster"
TEMPLATE="/home/feriel/temp.yaml"
ANSIBLE_PLAYBOOK_DIR="/root/k8s-ansible/playbooks"
ANSIBLE_PLAYBOOK="$ANSIBLE_PLAYBOOK_DIR/site.yml"
 
echo "=== VÉRIFICATION STACK EXISTANTE ==="
 
# Vérifier si la stack existe déjà
if openstack stack show "$STACK_NAME" &>/dev/null; then
    echo "⚠ Stack '$STACK_NAME' existe déjà"
    # Récupérer le status
    STACK_STATUS=$(openstack stack show "$STACK_NAME" -f value -c stack_status)
    echo "Status actuel: $STACK_STATUS"
    # Supprimer la stack
    echo "Suppression de la stack existante..."
    openstack stack delete "$STACK_NAME" --yes --wait
    echo "✓ Stack supprimée"
    # Attendre un peu pour être sûr
    sleep 5
else
    echo "✓ Aucune stack existante avec ce nom"
fi
 
echo -e "\n=== CRÉATION DE LA STACK ==="
openstack stack create -t "$TEMPLATE" "$STACK_NAME" --wait
 
echo "✓ Stack creation complete"
 
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
 
echo -e "\n=== VÉRIFICATION INVENTAIRE ==="
cd "$ANSIBLE_PLAYBOOK_DIR"
ansible-inventory --list

echo -e "\n=== EXÉCUTION ANSIBLE ==="
ansible-playbook site.yml
 
echo -e "\n✓ DÉPLOIEMENT TERMINÉ!"
