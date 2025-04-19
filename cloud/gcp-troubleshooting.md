## 🔧 GCP CLI Troubleshooting

> Authenticate with gcloud auth login and set your project:
gcloud config set project <PROJECT_ID>.

### General Diagnostics

```bash
gcloud info                             # Environment info
gcloud projects list                    # List accessible projects
gcloud services list                    # Enabled APIs
gcloud compute instances list           # List all VMs

```

### VM Issues

```bash
gcloud compute instances describe my-vm --zone=us-central1-a
gcloud compute ssh my-vm --zone=us-central1-a
gcloud compute instances get-serial-port-output my-vm --zone=us-central1-a
```

### Network & Load Balancer

```bash
gcloud compute firewall-rules list
gcloud compute networks list
gcloud compute routes list
gcloud compute forwarding-rules list

```

### Logs & Monitoring

```bash
gcloud logging read "resource.type=gce_instance AND severity>=ERROR" --limit 10
gcloud logging read "resource.type=k8s_container" --limit 10
gcloud logging logs list
gcloud monitoring metrics list --resource=gce_instance

```