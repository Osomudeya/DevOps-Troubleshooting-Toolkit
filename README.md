# DevOps Troubleshooting Toolkit

<div align="center">
  <img src="assets/images/repo-banner.png" alt="DevOps Troubleshooting Toolkit Banner" width="800px" />

  <br />

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
  [![GitHub stars](https://img.shields.io/github/stars/Osomudeya/DevOps-Troubleshooting-Toolkit.svg)](https://github.com/Osomudeya/DevOps-Troubleshooting-Toolkit/stargazers)
  [![GitHub forks](https://img.shields.io/github/forks/Osomudeya/DevOps-Troubleshooting-Toolkit.svg)](https://github.com/Osomudeya/DevOps-Troubleshooting-Toolkit/network/members)
   [![GitHub downloads](https://img.shields.io/github/downloads/Osomudeya/DevOps-Troubleshooting-Toolkit/total.svg)](https://github.com/Osomudeya/DevOps-Troubleshooting-Toolkit/releases)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin&style=social)](https://www.linkedin.com/in/osomudeya-zudonu-17290b124/)
</div>


> A comprehensive collection of commands, tools, and methodologies for troubleshooting DevOps environments - from Linux to Kubernetes and beyond.

## 📖 Table of Contents

- [About This Project](#about-this-project)
- [Quick Reference Guides](#quick-reference-guides)
- [Common Issues](#common-issues)
- [Content Organization](#content-organization)
- [Installation and Usage](#installation-and-usage)
- [Contributing](#contributing)
- [License](#license)
- [Related Resources](#related-resources)

## 🔎 About This Project

The DevOps Troubleshooting Toolkit is designed to be the definitive resource for diagnosing and resolving issues across the entire DevOps stack. This repository provides structured, practical guidance for engineers working with modern infrastructure and applications.

### Why This Toolkit Exists

As systems grow more complex and distributed, troubleshooting becomes increasingly challenging. This toolkit aims to:

- Provide structured approaches to solving common (and uncommon) problems
- Document real-world solutions tested in production environments
- Share institutional knowledge that typically takes years to accumulate
- Reduce mean time to resolution (MTTR) for critical incidents

### Who It's For

- DevOps Engineers handling infrastructure and deployment pipelines
- Site Reliability Engineers (SREs) maintaining production systems
- Platform Engineers building internal developer platforms
- System Administrators managing Linux environments
- Cloud Engineers working with AWS, GCP, Azure and other providers
- Backend Developers debugging application issues in complex environments

## 🚀 Quick Reference Guides

Jump directly to troubleshooting guides for common platforms:

| Platform | Quick Links |
|----------|-------------|
| **Linux** | [System Commands](linux/system-commands.md) • [Networking](linux/networking.md) • [Disk Storage](linux/disk-storage.md) • [Process Management](linux/process-management.md) |
| **Docker** | [Docker Troubleshooting](containers/docker-troubleshooting.md) • [Container Networking](containers/container-networking.md) • [Image Management](containers/image-management.md) |
| **Kubernetes** | [Cluster Management](kubernetes/cluster-management.md) • [Workload Troubleshooting](kubernetes/workload-troubleshooting.md) • [Kubernetes Networking](kubernetes/kubernetes-networking.md) |
| **Databases** | [Database Troubleshooting Commands](databases/database-troubleshooting.md)
| **Cloud** | [AWS](cloud/aws-troubleshooting.md) • [GCP](cloud/gcp-troubleshooting.md) • [Azure](cloud/azure-troubleshooting.md) |

## 🔥 Common Issues

Having a specific problem? Jump directly to these common troubleshooting scenarios:

### Application Access Issues
- [Application Service Not Responding](scenarios/networking-scenarios.md#application-service-not-responding)
- [Intermittent Connection Failures](networking/protocol-troubleshooting.md#intermittent-connection-failures)
- [DNS Resolution Problems](networking/dns-issues.md#dns-resolution-failures)

### Deployment Problems
- [Container Fails to Start](containers/docker-troubleshooting.md#container-fails-to-start)
- [Kubernetes Pod Stuck in Pending](kubernetes/workload-troubleshooting.md#pods-stuck-in-pending)
- [CI/CD Pipeline Failures](scenarios/system-scenarios.md#cicd-pipeline-failures)

### Performance Degradation
- [High CPU Usage Troubleshooting](linux/performance-tuning.md#cpu-optimization)
- [Memory Leaks and OOM Kills](linux/performance-tuning.md#memory-optimization)
- [Slow Database Queries](databases/relational-databases.md#performance-tuning)

### Storage Issues
- [Disk Space Alerts](linux/disk-storage.md#disk-space-issues)
- [Persistent Volume Claims Stuck](kubernetes/kubernetes-storage.md#persistent-volume-claim-issues)
- [I/O Bottlenecks](linux/performance-tuning.md#disk-io-optimization)


## 🚀 Getting Started

Navigate through the repository using the directory structure or use GitHub's search function to find specific commands:

```
# Example: Find all commands related to Kubernetes pods
# Use GitHub's search or navigate to:
kubernetes/workloads/pods.md
```

## 📂 Content Organization

This repository is organized into technology-specific sections, each with detailed troubleshooting guides:

- [**linux/**](linux/) - Linux system troubleshooting
- [**containers/**](containers/) - Container runtime issues (Docker, etc.)
- [**kubernetes/**](kubernetes/) - Kubernetes cluster and workload problems
- [**cloud/**](cloud/) - Cloud provider specific issues
- [**databases/**](databases/) - Database engines and data persistence
- [**networking/**](networking/) - Network connectivity and protocols
- [**observability/**](observability/) - Monitoring, logging, and tracing
- [**scripts/**](scripts/) - Useful troubleshooting scripts
- [**scenarios/**](scenarios/) - End-to-end troubleshooting scenarios

## 📊 Downloadable Resources

Get printable resources to keep handy during troubleshooting sessions:

- [DevOps Commands Cheatsheet](assets/cheatsheets/devops-commands.pdf)
- [Troubleshooting Flowcharts](assets/cheatsheets/troubleshooting-flows.pdf)

## 🛠️ Installation and Usage

### Local Use

Clone this repository to have the troubleshooting guides available locally:
```bash
git clone https://github.com/Osomudeya/DevOps-Troubleshooting-Toolkit.git
cd DevOps-Troubleshooting-Toolkit
```

### 🧪 Quick Database Connection Test
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
- Connect on [LinkedIn](https://www.linkedin.com/in/osomudeya-zudonu-17290b124)
- Follow on [Twitter](https://twitter.com/irvingpictures)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

If you find this repository helpful, please consider giving it a ⭐️ star ⭐️ to help others discover it too!

*Remember: The best troubleshooters aren't those who know all the answers, but those who know where to find them.*
