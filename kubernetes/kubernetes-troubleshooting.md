# Kubernetes Pod Troubleshooting

This document provides comprehensive commands, real-world scenarios, and techniques for diagnosing and resolving issues with Kubernetes pods.

## Table of Contents

- [Pod Status Investigation](#pod-status-investigation)
- [Pod Logs Analysis](#pod-logs-analysis)
- [Pod Description and Events](#pod-description-and-events)
- [Pod Debugging](#pod-debugging)
- [Common Pod Issues](#common-pod-issues)
- [Init Container Issues](#init-container-issues)
- [Exit Codes & What They Mean](#exit-codes--what-they-mean)
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

# Get logs from an init container
kubectl logs pod-name -c init-container-name

# Get logs from previous instance of a pod (if it crashed)
kubectl logs pod-name --previous

# Follow logs in real-time
kubectl logs -f pod-name

# Show only the most recent 20 lines
kubectl logs --tail=20 pod-name

# Show logs since a relative time
kubectl logs --since=1h pod-name

# Get logs from all containers in a pod
kubectl logs pod-name --all-containers
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
```

### Port Forwarding

```bash
kubectl port-forward pod-name 8080:80
kubectl port-forward --address 0.0.0.0 pod-name 8080:80
```

### Creating Debugging Pods

```bash
kubectl run debug-pod --rm -it --image=nicolaka/netshoot -- /bin/bash
kubectl debug pod-name -it --image=nicolaka/netshoot --target=pod-name
```

## Common Pod Issues

### CrashLoopBackOff

- Container keeps restarting due to failure.
- Use `kubectl logs` and `kubectl describe` to investigate.

### ImagePullBackOff / ErrImagePull

- Pod can't pull the image (wrong image name, tag, registry permissions).
- Use `kubectl describe pod pod-name` to check event logs.

### Pending

- Not enough resources on nodes or misconfigured node affinity.
- Check `kubectl describe pod pod-name` and node capacity.

### OOMKilled

- Out of memory.
- Use `kubectl describe pod` → Status → Exit Code `137`.

### Evicted

- Node out of memory/disk. Check node status and eviction events.

### ContainerCreating

- Volume mount or image pull issue.

### DNS/Network Issues

- Check CoreDNS pod logs and DNS resolution from inside pod.

## Init Container Issues

Init containers are used to **prepare the environment** before the main app starts. If any init container fails, the pod will never start.

### How to Identify Init Container Issues:

```bash
# Check status of init containers
kubectl describe pod pod-name

# View logs for a specific init container
kubectl logs pod-name -c init-container-name
```

### Common Problems:
- Wrong mount path or missing volume
- Crash in script (permissions, file not found)
- Wrong command or image

Fix by reviewing the `initContainers` section in your YAML:
```yaml
initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'echo hello && exit 1']
    volumeMounts:
      - name: shared-data
        mountPath: /data
```

Use logs to identify the failing command, and update accordingly.

## Exit Codes & What They Mean

```text
0     = Success
1     = General app error
126   = Permission problem (e.g. trying to run a non-executable)
127   = Command not found
128+n = Exit by signal (e.g., 137 = SIGKILL, 143 = SIGTERM)
139   = Segmentation fault
```

### Check Exit Code:
```bash
kubectl get pod pod-name -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}'
```

Use with `describe pod` or `logs` to investigate why a container exited.

## Container Health Checks

### Probe Configuration

```bash
kubectl describe pod pod-name | grep -A 5 Liveness
kubectl describe pod pod-name | grep -A 5 Readiness
kubectl get pod pod-name -o yaml | grep -A 15 livenessProbe
```

### Manual Probe Testing

```bash
kubectl exec pod-name -- curl -v http://localhost:8080/health
kubectl exec pod-name -- /path/to/command
kubectl exec -it pod-name -- nc -vz localhost 8080
```

## Pod Resource Utilization

### Resource Requests and Limits

```bash
kubectl describe pod pod-name | grep -A 5 Requests
kubectl get pod pod-name -o jsonpath='{.spec.containers[0].resources.requests}'
kubectl get pod pod-name -o jsonpath='{.spec.containers[0].resources.limits}'
```

### Resource Usage Monitoring

```bash
kubectl top pod pod-name
kubectl top pods
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory
```

## Pod Communication Debugging

### Network Connectivity

```bash
kubectl exec -it pod-name -- nslookup kubernetes.default.svc.cluster.local
kubectl exec -it pod-name -- curl -v service-name:port
kubectl exec -it pod-name -- nc -vz service-name port
kubectl exec -it pod-name -- curl -v https://www.google.com
```

### DNS Debugging

```bash
kubectl run dnsutils --rm -it --image=tutum/dnsutils -- bash
kubectl logs -n kube-system -l k8s-app=kube-dns
kubectl exec -it pod-name -- nslookup service-name.namespace.svc.cluster.local
```

### Sidecar Container Investigation

```bash
kubectl get pod pod-name -o jsonpath='{.spec.containers[*].name}'
kubectl logs pod-name -c sidecar-container-name
kubectl exec -it pod-name -c sidecar-container-name -- /bin/sh
kubectl get pod pod-name -o json | jq '.status.containerStatuses[] | {name, state, lastState, restartCount}'
kubectl get pod pod-name -o jsonpath='{.status.containerStatuses[?(@.name=="sidecar-container-name")]}'
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
7. **Inspect Node Status**
   ```bash
   kubectl describe node $(kubectl get pod pod-name -o jsonpath='{.spec.nodeName}')
   ```
8. **Create a Debug Pod**
   ```bash
   kubectl debug pod-name -it --image=nicolaka/netshoot --target=pod-name
   ```

### Quick Reference: Pod Problem → Command

| Problem | Command |
|---------|---------|
| Pod not starting | `kubectl describe pod pod-name` |
| Pod crashing | `kubectl logs pod-name --previous` |
| Container errors | `kubectl logs pod-name -c container-name` |
| Init container failing | `kubectl logs pod-name -c init-container-name` |
| Resource issues | `kubectl top pod pod-name` |
| Networking issues | `kubectl exec -it pod-name -- nc -vz service port` |
| Configuration problems | `kubectl get pod pod-name -o yaml` |
| Node issues | `kubectl describe node $(kubectl get pod pod-name -o jsonpath='{.spec.nodeName}')` |

---

Always validate your cluster’s context and namespace when troubleshooting, and remember: **describe and logs are your best friends.**

