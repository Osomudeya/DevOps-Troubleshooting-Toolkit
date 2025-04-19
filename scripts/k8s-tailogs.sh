#!/bin/bash

# logs.sh - stream logs for every pod matching a label selector

NAMESPACE=${1:-default}
LABEL_SELECTOR=${2:-app=my-app}

echo "Tailing logs in namespace '$NAMESPACE' for pods with label '$LABEL_SELECTOR'..."
kubectl logs -n "$NAMESPACE" -l "$LABEL_SELECTOR" --all-containers=true -f
