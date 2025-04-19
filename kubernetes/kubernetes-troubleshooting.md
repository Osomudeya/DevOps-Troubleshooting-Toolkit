# Kubernetes Pod Troubleshooting

This document provides comprehensive commands and techniques for diagnosing and resolving issues with Kubernetes pods.

## Table of Contents

- [Pod Status Investigation](#pod-status-investigation)
- [Pod Logs Analysis](#pod-logs-analysis)
- [Pod Description and Events](#pod-description-and-events)
- [Pod Debugging](#pod-debugging)
- [Common Pod Issues](#common-pod-issues)
- [Container Health Checks](#container-health-checks)
- [Pod Resource Utilization](#pod-resource-utilization)
- [Pod Communication Debugging](#pod-communication-debugging)
- [Troubleshooting CheckFlow](#troubleshooting-checkflow)

## Pod Status Investigation

### Basic Pod Status Commands

```bash
# List all pods in the current namespace
kubectl get pods

# List pods with more details
kubectl get pods -o wide

# List pods in all namespaces
kubectl get pods --all-namespaces

# List pods with their status and restart count
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'

# Watch pods in real-time
kubectl get pods -w
```

### Pod Status Phases

Pods go through different phases in their lifecycle:

- **Pending**: Pod has been accepted but containers are not running yet
- **Running**: Pod has been bound to a node and all containers are running
- **Succeeded**: All containers in the pod have terminated successfully
- **Failed**: All containers in the pod have terminated, at least one with failure
- **Unknown**: Pod state cannot be obtained

```bash
# Filter pods by phase
kubectl get pods --field-selector=status.phase=Running
kubectl get pods --field-selector=status.phase=Pending
kubectl get pods --field-selector=status.phase=Failed
```

## Pod Logs Analysis

### Basic Log Retrieval

```bash
# Get logs from a pod
kubectl logs pod-name

# Get logs from a specific container in a pod
kubectl logs pod-name -c container-name

# Get logs from previous instance of a pod (if it crashed)
kubectl logs pod-name --previous

# Follow logs in real-time
kubectl logs -f pod-name

# Show only the most recent 20 lines
kubectl logs --tail=20 pod-name

# Show logs since a relative time
kubectl logs --since=1h pod-name

kubectl logs pod-name --all-containers
kubectl logs pod-name -c init-container-name
```

### Advanced Log Techniques

```bash
# Get logs from all pods with a specific label
kubectl logs -l app=nginx

# Get logs from all containers in a pod
kubectl logs pod-name --all-containers

# Combine tail and follow
kubectl logs --tail=50 -f pod-name

# Output logs with timestamps
kubectl logs --timestamps=true pod-name

# View logs from init containers
kubectl logs pod-name -c init-container-name
```

## Pod Description and Events

### Detailed Pod Information

```bash
# Get detailed pod information
kubectl describe pod pod-name

# Get specific sections of pod information using jsonpath
kubectl get pod pod-name -o jsonpath='{.status.conditions[*].message}'

# Extract pod IP address
kubectl get pod pod-name -o jsonpath='{.status.podIP}'

# Extract node where pod is running
kubectl get pod pod-name -o jsonpath='{.spec.nodeName}'
```

### Pod Events

```bash
# Get all events in the current namespace
kubectl get events

# Get events related to pods
kubectl get events --field-selector involvedObject.kind=Pod

# Get events for a specific pod
kubectl get events --field-selector involvedObject.name=pod-name

# Sort events by timestamp
kubectl get events --sort-by='.lastTimestamp'

# Watch events in real-time
kubectl get events -w
```

## Pod Debugging

### Interactive Shell Access

```bash
# Get a shell to a running container
kubectl exec -it pod-name -- /bin/bash

# If bash is not available, try sh
kubectl exec -it pod-name -- /bin/sh

# Run commands directly without interactive shell
kubectl exec pod-name -- ls -la /app

# Execute command in a specific container of a pod
kubectl exec -it pod-name -c container-name -- /bin/bash

kubectl port-forward pod-name 8080:80

kubectl port-forward --address 0.0.0.0 pod-name 8080:80

kubectl run debug-pod --rm -it --image=nicolaka/netshoot -- /bin/bash

kubectl debug pod-name -it --image=nicolaka/netshoot --target=pod-name
```

### Port Forwarding

```bash
# Forward local port to pod port
kubectl port-forward pod-name 8080:80

# Forward to a specific container port in the pod
kubectl port-forward pod-name 8080:8080

# Allow access from any IP on your machine
kubectl port-forward --address 0.0.0.0 pod-name 8080:80
```

### Creating Debugging Pods

```bash
# Run a temporary debugging pod
kubectl run debug-pod --rm -it --image=nicolaka/netshoot -- /bin/bash

# Create a debug container that joins a pod's network namespace
kubectl debug pod-name -it --image=nicolaka/netshoot --target=pod-name
```

## Common Pod Issues

### Troubleshooting Pod Startup Issues

#### Pod Stuck in Pending Status

Possible causes:
- Insufficient cluster resources
- PersistentVolumeClaim (PVC) not binding
- Node selector/affinity requirements not met

```bash
# Check cluster resource usage
kubectl describe nodes

# Check if PVC is bound
kubectl get pvc

# Check pod events for scheduling errors
kubectl describe pod pod-name | grep -A 10 Events:
```

#### Pod Stuck in ContainerCreating Status

Possible causes:
- Image pull issues
- Volume mount problems
- Init container failures

```bash
# Check image pull status
kubectl describe pod pod-name | grep -A 5 Events:

# Check volume issues
kubectl describe pod pod-name | grep -A 10 Volumes:

# Check for any Secret or ConfigMap referenced but not found
kubectl describe pod pod-name | grep -A 5 "Error"
```

#### Pod in CrashLoopBackOff Status

Possible causes:
- Application error
- Resource constraints
- Incorrect configuration

```bash
# Check container logs
kubectl logs pod-name

# Check previous container logs if it has restarted
kubectl logs pod-name --previous

# Look for termination reason
kubectl describe pod pod-name | grep -A 5 "Last State"
```

### Pod Restart Issues

```bash
# Check restart count
kubectl get pods | grep pod-name

# Get container termination reason
kubectl get pod pod-name -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}'

# Check container exit code
kubectl get pod pod-name -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}'
```

Exit code meanings:
- `0`: Success
- `1`: General errors
- `128+n`: Fatal error signals (128 + signal number)
  - `137`: SIGKILL (128+9) - Often OOMKilled
  - `143`: SIGTERM (128+15)

## Container Health Checks

### Probe Configuration

```bash
# Check liveness probe configuration
kubectl describe pod pod-name | grep -A 5 Liveness

# Check readiness probe configuration
kubectl describe pod pod-name | grep -A 5 Readiness

# Get full probe details
kubectl get pod pod-name -o yaml | grep -A 15 livenessProbe
```

### Manual Probe Testing

```bash
# For HTTP probe testing
kubectl exec pod-name -- curl -v http://localhost:8080/health

# For command probe testing, execute the command directly
kubectl exec pod-name -- /path/to/command

# For TCP probe testing
kubectl exec -it pod-name -- nc -vz localhost 8080
```

## Pod Resource Utilization

### Resource Requests and Limits

```bash
# Check resource requests and limits
kubectl describe pod pod-name | grep -A 5 Requests

# Get specific resource requests
kubectl get pod pod-name -o jsonpath='{.spec.containers[0].resources.requests}'

# Get specific resource limits
kubectl get pod pod-name -o jsonpath='{.spec.containers[0].resources.limits}'
```

### Resource Usage Monitoring

```bash
# Install metrics-server if not already installed
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Get pod resource usage
kubectl top pod pod-name

# Get resource usage for all pods
kubectl top pods

# Sort pods by CPU usage
kubectl top pods --sort-by=cpu

# Sort pods by memory usage
kubectl top pods --sort-by=memory
```

## Pod Communication Debugging

### Network Connectivity

```bash
# Check if DNS is working
kubectl exec -it pod-name -- nslookup kubernetes.default.svc.cluster.local

# Check connectivity to service
kubectl exec -it pod-name -- curl -v service-name:port

# Verify network policies by testing connectivity
kubectl exec -it pod-name -- nc -vz service-name port

# Test connectivity to external endpoint
kubectl exec -it pod-name -- curl -v https://www.google.com
```

### DNS Debugging

```bash
# Run DNS debug pod
kubectl run dnsutils --rm -it --image=tutum/dnsutils -- bash

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Test DNS resolution
kubectl exec -it pod-name -- nslookup service-name.namespace.svc.cluster.local
```

### Sidecar Container Investigation

```bash
# List all containers in a pod
kubectl get pod pod-name -o jsonpath='{.spec.containers[*].name}'

# Check logs of the sidecar container
kubectl logs pod-name -c sidecar-container-name

# Exec into sidecar container
kubectl exec -it pod-name -c sidecar-container-name -- /bin/sh

# Check status of each container in a multi-container pod
kubectl get pod pod-name -o json | jq '.status.containerStatuses[] | {name, state, lastState, restartCount}'

# Describe only sidecar container
kubectl get pod pod-name -o jsonpath='{.status.containerStatuses[?(@.name=="sidecar-container-name")]}'

# Dump environment variables of the sidecar container
kubectl exec -it pod-name -c sidecar-container-name -- env

```


## Troubleshooting CheckFlow

Use this step-by-step process to diagnose pod issues systematically:

1. **Check Pod Status**
   ```bash
   kubectl get pod pod-name -o wide
   ```

2. **Examine Pod Events**
   ```bash
   kubectl describe pod pod-name
   ```

3. **Review Container Logs**
   ```bash
   kubectl logs pod-name [-c container-name]
   ```

4. **Verify Pod Configuration**
   ```bash
   kubectl get pod pod-name -o yaml
   ```

5. **Check Resource Constraints**
   ```bash
   kubectl top pod pod-name
   ```

6. **Verify Network Connectivity**
   ```bash
   kubectl exec -it pod-name -- curl -v service-name:port
   ```

7. **Inspect Node Status** (if node-related issues are suspected)
   ```bash
   kubectl describe node node-name
   ```

8. **Create a Debug Pod** (if needed for deeper investigation)
   ```bash
   kubectl debug pod-name -it --image=nicolaka/netshoot --target=pod-name
   ```

### Quick Reference: Pod Problem → Command

| Problem | Command |
|---------|---------|
| Pod not starting | `kubectl describe pod pod-name` |
| Pod crashing | `kubectl logs pod-name --previous` |
| Container errors | `kubectl logs pod-name -c container-name` |
| Resource issues | `kubectl top pod pod-name` |
| Networking issues | `kubectl exec -it pod-name -- nc -vz service port` |
| Configuration problems | `kubectl get pod pod-name -o yaml` |
| Node issues | `kubectl describe node $(kubectl get pod pod-name -o jsonpath='{.spec.nodeName}')` |

---

Remember to always check the Kubernetes version you're running, as some commands and features might vary between versions.