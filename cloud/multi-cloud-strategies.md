## 🔀 Multi-Cloud & General Tips

> Authenticate with gcloud auth login and set your project:
gcloud config set project <PROJECT_ID>.

### Terraform Debug

```bash
terraform plan -out=tf.plan
terraform apply tf.plan
TF_LOG=DEBUG terraform apply        # Debug mode
terraform state list                # View current state
terraform show                      # Show resource values


```

### Kubernetes Across Clouds (AKS, GKE, EKS)

```bash
kubectl config get-contexts             # List kubeconfigs
kubectl config use-context my-context  # Switch context
kubectl get nodes                      # Check cluster nodes
kubectl get pods -A                    # Check all pod health
kubectl describe pod <pod-name>        # Inspect pod errors

```

### SSH Access Troubleshooting

```bash
gcloud compute firewall-rules list
# Azure
az vm run-command invoke --command-id RunShellScript --scripts "whoami"

# GCP
gcloud compute ssh my-vm --zone=us-central1-a

# Common SSH failure fix
chmod 400 ~/.ssh/key.pem
ssh -i ~/.ssh/key.pem user@ip_address


```

### 📋 Common Issues & Quick Fixes

```bash
Issue | Cloud | Command
VM Not Starting | Azure | az vm get-instance-view
Pod Not Starting | Any K8s | kubectl describe pod <pod>
Service Not Reachable | Azure | az network watcher test-ip-flow
GKE Logs Not Visible | GCP | gcloud logging read "resource.type=k8s_container"
Load Balancer Failing | Azure | az network lb show -n myLB -g myGroup
Resource Quota Exceeded | GCP | gcloud compute regions describe us-central1
```

### 📎 Logs, Diagnostics & Metrics
Azure

```bash
az monitor log-analytics workspace list
az monitor metrics list --resource <resource-id>
az vm boot-diagnostics get-boot-log --name myVM --resource-group myGroup
```

### GCP

```bash
gcloud logging read 'severity>=ERROR' --limit 10
gcloud compute instances get-serial-port-output my-vm
gcloud monitoring dashboards list
```

### 🧪 Tools to Install

```bash
Tool | Use Case
Azure CLI | Azure resource management
gcloud CLI | Google Cloud resource management
kubectl | Kubernetes management
btop/htop | Process monitoring in VMs
terraform | Multi-cloud IaC provisioning
netshoot | Container networking/debug image
dig, nc | DNS and port testing
jq | JSON parsing and CLI filtering

💡 Pro Tip: Store your frequently used CLI scripts in a personal bin/ directory and version it with Git.
```

### 📡 Networking Debug

```bash
Tool | Description
nc | Test TCP/UDP ports
dig | DNS resolution
traceroute | Track route to host
ip route | View routing table
curl / wget | Test endpoint reachability
ping | ICMP tests
```

### Security & IAM

#### Azure

```bash
az role assignment list --assignee <user>
az ad user show --id user@example.com
az ad sp list --display-name <app-name>

```

### GCP

```bash
gcloud projects get-iam-policy <project>
gcloud iam roles list
gcloud auth list

```