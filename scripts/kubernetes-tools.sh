#!/bin/bash

# tools.sh - install essential tools into a Kubernetes namespace (e.g., dev-tools)

NAMESPACE=dev-tools

echo "Creating namespace: $NAMESPACE"
kubectl create ns $NAMESPACE || echo "Namespace already exists"

echo "Deploying debug pod (netshoot)..."
kubectl run netshoot --rm -it --image=nicolaka/netshoot -n $NAMESPACE -- bash

# Alternative: persistent pod
# kubectl run netshoot --image=nicolaka/netshoot -n $NAMESPACE -- sleep 3600

echo "Installing busybox..."
kubectl run busybox --rm -it --image=busybox:1.28 -n $NAMESPACE -- /bin/sh

echo "Done. You can now use tools like:"
echo "  - dig"
echo "  - curl"
echo "  - nslookup"
echo "  - tcpdump"