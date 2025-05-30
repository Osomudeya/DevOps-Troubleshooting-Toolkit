# ☁️ DevOps Scenario-Based Troubleshooting Guide

This guide provides real-world troubleshooting examples across DevOps workflows, including CI/CD, Docker, Kubernetes, and cloud environments.

---

## 🔥 Scenario 1: CI/CD Pipeline Failing on Deployment Step

**Symptom:**
- Build passes
- Deployment fails with `permission denied` or resource not found

**Checklist & Fix:**
```bash
# Check service principal or GitHub token permissions
az ad sp show --id <client-id>
az role assignment list --assignee <client-id>

# Check deployment logs (e.g. Azure DevOps, GitHub Actions)
cat deployment.log

# Validate secrets in pipeline
echo $AZURE_CREDENTIALS | jq .

# Check if target resource exists
az webapp show --name my-app --resource-group my-group
```

---

## 🐳 Scenario 2: Docker Container Crashes Immediately After Start

**Symptom:**
- `docker ps -a` shows exit code 1 or 137

**Checklist & Fix:**
```bash
docker logs container_id
docker inspect container_id | jq '.[].State'
docker run -it image-name bash
```

---

## 🧠 Scenario 3: Kubernetes Pod Stuck in CrashLoopBackOff

**Symptom:**
- `kubectl get pods` shows repeated restarts

**Checklist & Fix:**
```bash
kubectl describe pod pod-name
kubectl logs pod-name
kubectl logs pod-name --previous
kubectl get events --sort-by='.lastTimestamp'
kubectl logs pod-name -c init-container-name
```

---

## 🚫 Scenario 4: 502/504 Gateway Errors in AKS Application

**Symptom:**
- Ingress returns 502/504
- App not reachable

**Checklist & Fix:**
```bash
kubectl get ingress
kubectl describe ingress
kubectl get svc
kubectl get endpoints
kubectl describe pod pod-name
```

---

## ⚠️ Scenario 5: High CPU Usage Detected in Production

**Symptom:**
- Alerts on CPU or memory threshold breach

**Checklist & Fix:**
```bash
top
htop
ps aux --sort=-%cpu | head

kubectl top pod
kubectl describe node node-name

az monitor metrics list --resource <vm-id> --metric "Percentage CPU"
```