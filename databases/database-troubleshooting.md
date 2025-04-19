# DevOps Troubleshooting Arsenal 🛠️

[![GitHub stars](https://img.shields.io/github/stars/yourusername/devops-troubleshooting-arsenal.svg)](https://github.com/yourusername/devops-troubleshooting-arsenal/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin&style=social)](https://www.linkedin.com/in/osomudeya-zudonu-17290b124/)
[![Code of Conduct](https://img.shields.io/badge/Code%20of-Conduct-purple.svg)](CODE_OF_CONDUCT.md)

A comprehensive, searchable collection of troubleshooting commands and techniques for DevOps professionals. From Linux system analysis to Kubernetes cluster debugging, find the command you need when you need it most.

> "The right command at the right time saves hours of debugging." — DevOps Wisdom

## 🔍 What's Inside

This repository contains troubleshooting commands and procedures for:

- **[Linux Systems](#linux)**: System performance, log analysis, process management
- **[Containers](#containers)**: Docker and containerd troubleshooting
- **[Kubernetes](#kubernetes)**: Cluster, workloads, networking, and storage issues
- **[Databases](#databases)**: Database management and performance optimization
- **[Observability](#observability)**: Prometheus, Grafana, and monitoring solutions
- **[Cloud Providers](#cloud)**: AWS, Azure, GCP, and multi-cloud strategies
- **[Scenarios](#scenarios)**: Real-world troubleshooting scenarios
- **[Scripts](#scripts)**: Automation scripts for common tasks

## 🚀 Getting Started

Navigate through the repository using the directory structure or use GitHub's search function to find specific commands:

```bash
# Example: Find all commands related to Kubernetes troubleshooting
# Use GitHub's search or navigate to:
kubernetes/kubernetes-troubleshooting.md
```

Each file contains:
- Commands with clear explanations
- Expected output examples
- Common error messages and their solutions
- Real-world troubleshooting scenarios

## 📚 Core Categories

<a name="linux"></a>
### 🐧 Linux

```bash
# Quick system health check
vmstat 1 5
free -h
df -h
netstat -tuln
```

[View Linux Commands →](linux/linux-commands.md)

<a name="containers"></a>
### 🐳 Containers

```bash
# Docker container inspection
docker logs container_id
docker inspect container_id
docker stats container_id
```

[View Docker Troubleshooting →](containers/docker-troubleshooting.md)

<a name="kubernetes"></a>
### ☸️ Kubernetes

```bash
# Pod troubleshooting
kubectl describe pod pod_name
kubectl logs pod_name -c container_name
kubectl exec -it pod_name -- /bin/bash
```

[View Kubernetes Troubleshooting →](kubernetes/kubernetes-troubleshooting.md)

<a name="databases"></a>
### 💾 Databases

```bash
# Database connection check
mysql -h hostname -u username -p -e "SELECT 1"
psql -h hostname -U username -c "SELECT 1"
mongo --host hostname --eval "db.stats()"
```

[View Database Troubleshooting →](databases/database-troubleshooting.md)

<a name="observability"></a>
### 📊 Observability

```bash
# Check Prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq .
```

[View Prometheus and Grafana Guide →](observability/prometheus-and-grafana.md)

<a name="cloud"></a>
### ☁️ Cloud Providers

- [AWS Troubleshooting →](cloud/aws-troubleshooting.md)
- [Azure Troubleshooting →](cloud/azure-troubleshooting.md)
- [GCP Troubleshooting →](cloud/gcp-troubleshooting.md)
- [Multi-Cloud Strategies →](cloud/multi-cloud-strategies.md)

<a name="scenarios"></a>
### 🧩 Troubleshooting Scenarios

Real-world examples to practice your troubleshooting skills:

[View Scenarios →](scenarios/scenarios.md)

<a name="scripts"></a>
### 📜 Useful Scripts

Automation scripts for common DevOps tasks:

- [Auto-Clone All Repos →](scripts/auto-clone-all-repos.sh)
- [Auto-Pull All Repos →](scripts/auto-pull-all-repos.sh)
- [Kubernetes Event Watcher →](scripts/kubernetes-events.sh)
- [Kubernetes Logs Tailer →](scripts/k8s-tailogs.sh)
- [Kubernetes Tools Installer →](scripts/kubernetes-tools.sh)

## 📋 Complete File Directory

### Linux
- [Linux Commands & Troubleshooting](linux/linux-commands.md)

### Containers
- [Docker Troubleshooting](containers/docker-troubleshooting.md)

### Kubernetes
- [Kubernetes Troubleshooting](kubernetes/kubernetes-troubleshooting.md)

### Databases
- [Database Troubleshooting](databases/database-troubleshooting.md)

### Observability
- [Prometheus and Grafana](observability/prometheus-and-grafana.md)

### Cloud
- [AWS Troubleshooting](cloud/aws-troubleshooting.md)
- [Azure Troubleshooting](cloud/azure-troubleshooting.md)
- [GCP Troubleshooting](cloud/gcp-troubleshooting.md)
- [Multi-Cloud Strategies](cloud/multi-cloud-strategies.md)

### Scenarios
- [Troubleshooting Scenarios](scenarios/scenarios.md)

### Scripts
- [auto-clone-all-repos.sh](scripts/auto-clone-all-repos.sh) - Clone all repositories from an organization
- [auto-pull-all-repos.sh](scripts/auto-pull-all-repos.sh) - Update all local repositories
- [k8s-tailogs.sh](scripts/k8s-tailogs.sh) - Stream logs from multiple Kubernetes pods
- [kubernetes-events.sh](scripts/kubernetes-events.sh) - Monitor Kubernetes events in real-time
- [kubernetes-tools.sh](scripts/kubernetes-tools.sh) - Install essential Kubernetes tools

## 🌟 How to Contribute

Contributions make this repository better! Whether it's:

1. Adding new commands
2. Improving existing explanations
3. Fixing errors
4. Adding real-world examples

Check out our [Contribution Guide](CONTRIBUTING.md) to get started.

## 🔄 Recently Updated

| File | Last Updated | Description |
|------|--------------|-------------|
| [kubernetes-troubleshooting.md](kubernetes/kubernetes-troubleshooting.md) | 2025-04-15 | Added EKS-specific troubleshooting |
| [aws-troubleshooting.md](cloud/aws-troubleshooting.md) | 2025-04-10 | Added Lambda troubleshooting |
| [prometheus-and-grafana.md](observability/prometheus-and-grafana.md) | 2025-04-05 | Updated for Prometheus 2.45 |

## 📱 Connect With Me

- Follow me on [Medium](https://medium.com/@osomudeyazudonu)
- Connect on [LinkedIn](https://www.linkedin.com/in/osomudeya-zudonu-17290b124/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

If you find this repository helpful, please consider giving it a ⭐️ star ⭐️ to help others discover it too!

*Remember: The best troubleshooters aren't those who know all the answers, but those who know where to find them.*