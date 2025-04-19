#!/bin/bash

# events.sh - list and sort Kubernetes events in a namespace

NAMESPACE=${1:-default}

echo "Fetching all events in namespace: $NAMESPACE"
kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' \
  -o custom-columns=TIME:.lastTimestamp,TYPE:.type,REASON:.reason,OBJECT:.involvedObject.name,MESSAGE:.message
