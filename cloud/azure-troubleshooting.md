## 🔧 Azure CLI Troubleshooting

> Make sure you're logged in with `az login`.

### General Diagnostics

```bash
az account show                          # Show current subscription
az resource list                         # List all resources
az group list                            # List resource groups
az vm list -d -o table                   # List VMs and IPs
az resource show --ids <resource-id>     # Detailed resource info
```

### VM Issues

```bash
az vm list -d -o table
az vm get-instance-view -g myGroup -n myVM
az vm show -g myGroup -n myVM -d
az vm run-command invoke -g myGroup -n myVM --command-id RunShellScript --scripts "df -h"

```

### Network & Load Balancer

```bash
az network nic list
az network public-ip list
az network lb list
az network watcher test-ip-flow --resource-group myGroup --vm-name myVM --local 10.0.0.4 --remote 8.8.8.8 --direction Outbound --protocol TCP
```

### Logs & Monitoring

```bash
az monitor diagnostic-settings list --resource <resource-id>
az monitor metrics list --resource <resource-id> --metric "Percentage CPU"
az monitor activity-log list --status Failed --max-events 10
```