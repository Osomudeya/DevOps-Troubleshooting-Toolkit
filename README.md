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
- [Quick Start](#quick-start)
- [Platform Guides](#platform-guides)
- [Common Issues](#common-issues)
- [Troubleshooting Scenarios](#troubleshooting-scenarios)
- [Useful Scripts](#useful-scripts)
- [Content Organization](#content-organization)
- [Installation and Usage](#installation-and-usage)
- [Contributing](#contributing)
- [Resources](#resources)
- [License](#license)

## 🔎 About This Project

The DevOps Troubleshooting Toolkit is designed to be the definitive resource for diagnosing and resolving issues across the entire DevOps stack. This repository provides structured, practical guidance for engineers working with modern infrastructure and applications.

### Why This Toolkit Exists

As systems grow more complex and distributed, troubleshooting becomes increasingly challenging. This toolkit aims to:

- ✅ Provide structured approaches to solving common (and uncommon) problems
- ✅ Document real-world solutions tested in production environments
- ✅ Share institutional knowledge that typically takes years to accumulate
- ✅ Reduce mean time to resolution (MTTR) for critical incidents
- ✅ Offer copy-paste commands for immediate use

### Who It's For

- **DevOps Engineers** - Infrastructure and deployment pipeline management
- **Site Reliability Engineers (SREs)** - Production system maintenance
- **Platform Engineers** - Internal developer platform building
- **System Administrators** - Linux environment management
- **Cloud Engineers** - Multi-cloud provider expertise
- **Backend Developers** - Application debugging in complex environments

## 🚀 Quick Start

### Emergency Commands

```bash
# System Health Check
top -p $(pgrep -d',' -f your_app)
free -h && df -h
netstat -tulpn | grep LISTEN

# Container Quick Debug
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker logs --tail 100 -f container_name

# Kubernetes Emergency
kubectl get pods --all-namespaces | grep -v Running
kubectl top nodes && kubectl top pods
```

### Installation

```bash
# Clone the repository
git clone https://github.com/Osomudeya/DevOps-Troubleshooting-Toolkit.git
cd DevOps-Troubleshooting-Toolkit

# Make scripts executable
chmod +x scripts/*.sh

# Optional: Add to PATH for global access
echo 'export PATH=$PATH:'$(pwd)'/scripts' >> ~/.bashrc
source ~/.bashrc
```

## 🛠️ Platform Guides

### Linux Systems
| Component | Quick Access | Description |
|-----------|--------------|-------------|
| **Linux Commands** | [`linux/linux-commands.md`](linux/linux-commands.md) | Essential system diagnostics and troubleshooting |

### Container Platforms
| Platform | Quick Access | Key Features |
|----------|--------------|--------------|
| **Docker** | [`containers/docker-troubleshooting.md`](containers/docker-troubleshooting.md) | Container lifecycle, networking, volumes |

### Kubernetes
| Component | Quick Access | Coverage |
|-----------|--------------|----------|
| **Kubernetes** | [`kubernetes/kubernetes-troubleshooting.md`](kubernetes/kubernetes-troubleshooting.md) | Cluster management, workloads, networking |

### Cloud Providers
| Provider | Quick Access | Specializations |
|----------|--------------|-----------------|
| **AWS** | [`cloud/aws-troubleshooting.md`](cloud/aws-troubleshooting.md) | EKS, Lambda, RDS, VPC troubleshooting |
| **GCP** | [`cloud/gcp-troubleshooting.md`](cloud/gcp-troubleshooting.md) | GKE, Cloud Functions, networking |
| **Azure** | [`cloud/azure-troubleshooting.md`](cloud/azure-troubleshooting.md) | AKS, App Services, resource groups |
| **Multi-Cloud** | [`cloud/multi-cloud-strategies.md`](cloud/multi-cloud-strategies.md) | Cross-platform strategies |

### Databases
| Database | Quick Access | Focus Areas |
|----------|--------------|-------------|
| **Database Troubleshooting** | [`databases/database-troubleshooting.md`](databases/database-troubleshooting.md) | Connection, performance, backup issues |

### Observability
| Tool | Quick Access | Coverage |
|------|--------------|----------|
| **Prometheus & Grafana** | [`observability/prometheus-and-grafana.md`](observability/prometheus-and-grafana.md) | Monitoring, alerting, dashboards |

## 🔥 Common Issues

### 🚨 Critical System Issues

#### High Load Average
```bash
# Quick diagnosis
uptime && cat /proc/loadavg
ps aux --sort=-%cpu | head -10
iostat -x 1 5

# Deep dive
sar -u 1 10  # CPU utilization
sar -d 1 10  # Disk activity
```
👉 **Detailed Guide**: [`linux/linux-commands.md`](linux/linux-commands.md)

#### Out of Memory (OOM)
```bash
# Check OOM killer logs
dmesg | grep -i "killed process"
journalctl -u your-service | grep -i oom

# Memory analysis
free -h && cat /proc/meminfo
ps aux --sort=-%mem | head -10
```
👉 **Detailed Guide**: [`linux/linux-commands.md`](linux/linux-commands.md)

#### Disk Space Full
```bash
# Find large files and directories
df -h
du -sh /* 2>/dev/null | sort -hr | head -10
find / -type f -size +1G 2>/dev/null

# Log rotation check
journalctl --disk-usage
```
👉 **Detailed Guide**: [`linux/linux-commands.md`](linux/linux-commands.md)

### 🐳 Container Issues

#### Container Won't Start
```bash
# Debug container startup
docker logs container_name
docker inspect container_name
docker run --rm -it image_name /bin/sh

# Resource constraints
docker stats container_name
```
👉 **Detailed Guide**: [`containers/docker-troubleshooting.md`](containers/docker-troubleshooting.md)

#### Container Networking
```bash
# Network debugging
docker network ls
docker inspect network_name
docker exec container_name netstat -tulpn
```
👉 **Detailed Guide**: [`containers/docker-troubleshooting.md`](containers/docker-troubleshooting.md)

### ☸️ Kubernetes Issues

#### Pods Stuck in Pending
```bash
# Check pod status
kubectl describe pod pod_name
kubectl get events --sort-by=.metadata.creationTimestamp

# Resource availability
kubectl top nodes
kubectl describe nodes
```
👉 **Detailed Guide**: [`kubernetes/kubernetes-troubleshooting.md`](kubernetes/kubernetes-troubleshooting.md)

#### Service Not Accessible
```bash
# Service debugging
kubectl get svc,ep service_name
kubectl describe svc service_name
kubectl get pods -l app=your_app -o wide
```
👉 **Detailed Guide**: [`kubernetes/kubernetes-troubleshooting.md`](kubernetes/kubernetes-troubleshooting.md)

### 🌐 Network Issues

#### DNS Resolution Failures
```bash
# DNS troubleshooting
nslookup domain.com
dig domain.com
systemd-resolve --status
```

#### Connection Timeouts
```bash
# Network connectivity
telnet host port
nc -zv host port
traceroute host
```

### 💾 Database Issues

#### Connection Problems
```bash
# Database connection check
mysql -h hostname -u username -p -e "SELECT 1"
psql -h hostname -U username -c "SELECT 1"
mongo --host hostname --eval "db.stats()"
```
👉 **Detailed Guide**: [`databases/database-troubleshooting.md`](databases/database-troubleshooting.md)

## 📊 Troubleshooting Scenarios

### Real-World Examples

| Scenario | Difficulty | Description | Guide |
|----------|------------|-------------|-------|
| **Complete Troubleshooting Scenarios** | 🟢-🔴 All Levels | End-to-end troubleshooting examples | [`scenarios/scenarios.md`](scenarios/scenarios.md) |

## 🛠️ Useful Scripts

### Available Scripts
- [`scripts/auto-clone-all-repos.sh`](scripts/auto-clone-all-repos.sh) - Clone all repositories from an organization
- [`scripts/auto-pull-all-repos.sh`](scripts/auto-pull-all-repos.sh) - Update all local repositories
- [`scripts/k8s-tailogs.sh`](scripts/k8s-tailogs.sh) - Stream logs from multiple Kubernetes pods
- [`scripts/kubernetes-events.sh`](scripts/kubernetes-events.sh) - Monitor Kubernetes events in real-time
- [`scripts/kubernetes-tools.sh`](scripts/kubernetes-tools.sh) - Install essential Kubernetes tools

### Usage Examples
```bash
# Repository management
./scripts/auto-clone-all-repos.sh    # Clone all org repositories
./scripts/auto-pull-all-repos.sh     # Update all local repositories

# Kubernetes tools
./scripts/kubernetes-events.sh       # Monitor K8s events real-time
./scripts/k8s-tailogs.sh            # Stream logs from multiple pods
./scripts/kubernetes-tools.sh       # Install essential K8s tools
```

## 📂 Content Organization

```
DevOps-Troubleshooting-Toolkit/
├── linux/                     # Linux system troubleshooting
│   └── linux-commands.md      # Essential Linux commands
├── containers/                 # Container platform issues
│   └── docker-troubleshooting.md # Docker troubleshooting guide
├── kubernetes/                 # K8s cluster and workload problems
│   └── kubernetes-troubleshooting.md # Kubernetes troubleshooting
├── cloud/                      # Cloud provider specific guides
│   ├── aws-troubleshooting.md  # AWS troubleshooting
│   ├── azure-troubleshooting.md # Azure troubleshooting
│   ├── gcp-troubleshooting.md  # GCP troubleshooting
│   └── multi-cloud-strategies.md # Multi-cloud strategies
├── databases/                  # Database troubleshooting
│   └── database-troubleshooting.md # Database issues
├── observability/              # Monitoring, logging, and tracing
│   └── prometheus-and-grafana.md # Prometheus & Grafana guide
├── scenarios/                  # End-to-end troubleshooting scenarios
│   └── scenarios.md           # Real-world scenarios
├── scripts/                    # Automated troubleshooting scripts
│   ├── auto-clone-all-repos.sh
│   ├── auto-pull-all-repos.sh
│   ├── k8s-tailogs.sh
│   ├── kubernetes-events.sh
│   └── kubernetes-tools.sh
└── assets/
    ├── images/                 # Repository images and diagrams
    └── cheatsheets/           # Printable reference materials
```

## 🧪 Quick Tests & Validation

### Database Connectivity
```bash
# MySQL/MariaDB
mysql -h hostname -u username -p -e "SELECT VERSION(), NOW();"

# PostgreSQL
psql -h hostname -U username -c "SELECT version();"

# MongoDB
mongosh --host hostname --eval "db.runCommand({ping: 1})"

# Redis
redis-cli -h hostname ping
```

### Service Health Checks
```bash
# HTTP services
curl -I http://service-endpoint/health
wget --spider http://service-endpoint/health

# TCP services
nc -zv hostname port
telnet hostname port
```

### Container Registry Access
```bash
# Docker Hub
docker pull hello-world

# Private registry
docker login registry.company.com
docker pull registry.company.com/app:latest
```

## 📊 Observability & Monitoring

### Prometheus & Grafana
```bash
# Check Prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq .

# Grafana API health
curl -H "Authorization: Bearer $GRAFANA_TOKEN" http://localhost:3000/api/health
```
👉 **Full Guide**: [`observability/prometheus-and-grafana.md`](observability/prometheus-and-grafana.md)

## 🔄 Recently Updated

| File | Last Updated | Changes |
|------|-------------|---------|
| [`kubernetes/kubernetes-troubleshooting.md`](kubernetes/kubernetes-troubleshooting.md) | 2025-05-30 | Added EKS-specific troubleshooting scenarios |
| [`cloud/aws-troubleshooting.md`](cloud/aws-troubleshooting.md) | 2025-05-28 | Enhanced Lambda cold start debugging |
| [`observability/prometheus-and-grafana.md`](observability/prometheus-and-grafana.md) | 2025-05-25 | Updated for Prometheus 2.50+ features |
| [`scripts/kubernetes-tools.sh`](scripts/kubernetes-tools.sh) | 2025-05-20 | Added resource quota validation |

## 🌟 How to Contribute

We welcome contributions from the community! Here's how you can help:

### Quick Contributions
- 🐛 **Report bugs** - Found an issue? [Create an issue](https://github.com/Osomudeya/DevOps-Troubleshooting-Toolkit/issues)
- 📖 **Improve docs** - Fix typos, add examples, enhance explanations
- 🔧 **Add commands** - Share your troubleshooting commands and techniques
- 🎯 **Real scenarios** - Document actual production issues you've solved

### Development Setup
```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/DevOps-Troubleshooting-Toolkit.git
cd DevOps-Troubleshooting-Toolkit

# Create feature branch
git checkout -b feature/new-troubleshooting-guide

# Make changes and test
./scripts/validate-docs.sh

# Submit PR
git push origin feature/new-troubleshooting-guide
```

👉 **Detailed Guide**: [`CONTRIBUTING.md`](CONTRIBUTING.md)

## 📋 Resources

### Downloadable Materials
- 📄 [DevOps Commands Cheatsheet](assets/cheatsheets/devops-commands.pdf)
- 📊 [Troubleshooting Flowcharts](assets/cheatsheets/troubleshooting-flows.pdf)

### External Resources
- 🌐 [Linux Performance Tools](http://www.brendangregg.com/linuxperf.html)
- 📚 [Kubernetes Troubleshooting Guide](https://kubernetes.io/docs/tasks/debug-application-cluster/)
- 🔧 [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### Community & Support
- 💬 [Discussions](https://github.com/Osomudeya/DevOps-Troubleshooting-Toolkit/discussions)
- 🐛 [Issues](https://github.com/Osomudeya/DevOps-Troubleshooting-Toolkit/issues)

## 📱 Connect & Follow

- 📖 [Medium Articles](https://medium.com/@osomudeyazudonu)
- 💼 [LinkedIn](https://www.linkedin.com/in/osomudeya-zudonu-17290b124)
- 🐦 [Twitter](https://twitter.com/irvingpictures)

## 📄 License

This project is licensed under the MIT License - see the [`LICENSE`](LICENSE) file for details.

---

<div align="center">

### ⭐ If this toolkit helped you solve a problem, please star the repository! ⭐

*"The best troubleshooters aren't those who know all the answers, but those who know where to find them."*

**Happy Troubleshooting! 🚀**

</div>