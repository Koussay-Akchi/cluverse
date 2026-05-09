#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$SCRIPT_DIR"

echo "=== Deploying Cluverse to Kubernetes ==="

echo "[1/6] Creating namespace..."
kubectl apply -f "$K8S_DIR/namespace.yml"

echo "[2/6] Deploying config and secrets..."
kubectl apply -f "$K8S_DIR/configmap.yml"
kubectl apply -f "$K8S_DIR/secrets.yml"

echo "[3/6] Deploying MySQL..."
kubectl apply -f "$K8S_DIR/mysql.yml"
echo "Waiting for MySQL..."
kubectl -n cluverse wait --for=condition=ready pod -l app=mysql --timeout=180s

echo "[4/6] Deploying Eureka Server..."
kubectl apply -f "$K8S_DIR/eureka-server.yml"
echo "Waiting for Eureka..."
kubectl -n cluverse wait --for=condition=ready pod -l app=eureka-server --timeout=180s

echo "[5/6] Deploying microservices..."
for svc in user-cluverse elections-cluverse events-cluverse competencies-cluverse logistics-cluverse finance-cluverse sponsors-cluverse; do
    kubectl apply -f "$K8S_DIR/$svc.yml"
done

kubectl apply -f "$K8S_DIR/bio-generator.yml"
kubectl apply -f "$K8S_DIR/speech-analyzer.yml"
kubectl apply -f "$K8S_DIR/cashflow.yml"
kubectl apply -f "$K8S_DIR/stripe-fraud.yml"

echo "[6/6] Deploying API Gateway and Frontend..."
kubectl apply -f "$K8S_DIR/api-gateway.yml"
kubectl apply -f "$K8S_DIR/frontend.yml"

echo ""
echo "Waiting for API Gateway..."
kubectl -n cluverse wait --for=condition=ready pod -l app=api-gateway --timeout=180s

echo ""
echo "=== Deployment Complete ==="
kubectl -n cluverse get pods -o wide
echo ""
kubectl -n cluverse get svc
