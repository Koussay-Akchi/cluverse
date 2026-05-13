#!/bin/bash

# Configuration
NAMESPACE="cluverse"
HPA_NAME="finance-cluverse-hpa"
SERVICE_URL="http://finance-cluverse.${NAMESPACE}.svc.cluster.local:8080/api/transactions"
LOAD_GEN_POD="hpa-load-generator"

echo "=== Kubernetes HPA Load Test Tool ==="
echo "Target: $SERVICE_URL"
echo "HPA: $HPA_NAME"
echo "======================================"

# Function to check HPA status
check_hpa() {
    echo "Current HPA Status:"
    kubectl -n $NAMESPACE get hpa $HPA_NAME
}

# Function to start load
start_load() {
    echo "Cleaning up any existing load generator..."
    kubectl -n $NAMESPACE delete pod $LOAD_GEN_POD --ignore-not-found=true --force --grace-period=0

    echo "Starting load generator pod (multiple concurrent loops)..."
    kubectl -n $NAMESPACE run $LOAD_GEN_POD --image=busybox -- /bin/sh -c "for i in 1 2 3 4 5; do (while true; do wget -q -O- $SERVICE_URL > /dev/null; done &); done; wait"
    echo "Load generator started. Monitoring HPA..."
    
    # Monitor loop
    while true; do
        clear
        echo "=== Monitoring Autoscaling (Ctrl+C to stop) ==="
        kubectl -n $NAMESPACE get hpa $HPA_NAME
        echo "-----------------------------------------------"
        kubectl -n $NAMESPACE get pods -l app=finance-cluverse
        sleep 5
    done
}

# Function to clean up
cleanup() {
    echo -e "\nCleaning up..."
    kubectl -n $NAMESPACE delete pod $LOAD_GEN_POD --force --grace-period=0
    echo "Done."
    exit
}

# Trap Ctrl+C
trap cleanup SIGINT

# Initial check
check_hpa

read -p "Press Enter to start load generation (or Ctrl+C to exit)..."

start_load
