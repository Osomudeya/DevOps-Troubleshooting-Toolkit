# Docker Troubleshooting Guide

This comprehensive guide provides commands, techniques, and real-world solutions for troubleshooting Docker containers, images, networks, and storage issues.

## Table of Contents

- [Container Lifecycle Issues](#container-lifecycle-issues)
- [Image Problems](#image-problems)
- [Networking Troubleshooting](#networking-troubleshooting)
- [Storage and Volume Issues](#storage-and-volume-issues)
- [Resource Constraints](#resource-constraints)
- [Docker Daemon Issues](#docker-daemon-issues)
- [Security Problems](#security-problems)
- [Logging and Debugging](#logging-and-debugging)
- [Performance Optimization](#performance-optimization)
- [Cleanup Operations](#cleanup-operations)

## Container Lifecycle Issues

### Container Won't Start

```bash
# Check container status
docker ps -a

# View detailed container information
docker inspect container_id

# Check container logs
docker logs container_id

# Check for error messages
docker logs container_id 2>&1 | grep -i error

# Start container with interactive shell for debugging
docker run -it --entrypoint /bin/sh image_name
```

When a container won't start, the most common issues are:

1. **Incorrect configuration**: Check environment variables and command arguments
2. **Missing dependencies**: Ensure all required services are available
3. **Permission issues**: Verify file permissions for mounted volumes
4. **Resource constraints**: Check if the system has enough resources

### Container Exits Immediately

```bash
# Run with interactive terminal to prevent immediate exit
docker run -it image_name /bin/bash

# Check exit code from the last run
docker inspect container_id --format='{{.State.ExitCode}}'

# Run with removed entrypoint to debug
docker run -it --entrypoint /bin/sh image_name
```

Common exit codes and their meanings:

| Exit Code | Meaning |
|-----------|---------|
| 0 | Success |
| 1 | General error |
| 125 | Docker daemon error |
| 126 | Command cannot be invoked |
| 127 | Command not found |
| 137 | Container received SIGKILL (often OOM) |
| 143 | Container received SIGTERM |

### Container Health Checks

```bash
# View container health status
docker inspect --format='{{.State.Health.Status}}' container_id

# See health check command results
docker inspect --format='{{json .State.Health}}' container_id | jq

# Manually run the health check command inside the container
docker exec container_id command_from_healthcheck
```

## Image Problems

### Image Pull Failures

```bash
# Check Docker Hub connectivity
curl -v https://registry-1.docker.io/v2/

# Pull with verbose output
docker pull --verbose image_name

# Check disk space
df -h

# Check Docker credentials
docker login
```

Common pull failure reasons:
- Network connectivity issues
- Authentication problems
- Rate limiting (especially for Docker Hub)
- Insufficient disk space

### Build Failures

```bash
# Build with verbose output
docker build --progress=plain -t image_name .

# Check Dockerfile syntax
docker build --no-cache -t image_name .

# Debug specific build stage
docker build --target stage_name -t image_name .
```

### Layer Inspection

```bash
# Inspect image layers
docker history image_name

# View detailed image information
docker inspect image_name

# Export image filesystem for inspection
docker save image_name > image.tar
mkdir -p image_contents && tar -xf image.tar -C image_contents
```

## Networking Troubleshooting

### Container Network Connectivity

```bash
# List networks
docker network ls

# Inspect network details
docker network inspect network_name

# Check container IP and network settings
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_id

# Check port mappings
docker port container_id

# Install debugging tools in a running container
docker exec container_id apt-get update && apt-get install -y iputils-ping net-tools curl
```

### Common Network Debugging Commands Inside Containers

```bash
# Test DNS resolution
docker exec container_id nslookup google.com

# Check network connectivity
docker exec container_id ping -c 4 8.8.8.8

# Trace network route
docker exec container_id traceroute google.com

# Check listening ports inside container
docker exec container_id netstat -tulpn
```

### DNS Issues

```bash
# Check Docker daemon DNS settings
docker info | grep -i dns

# Override DNS for a container
docker run --dns=8.8.8.8 image_name

# Check Docker DNS configuration in daemon.json
cat /etc/docker/daemon.json

# Check resolv.conf inside container
docker exec container_id cat /etc/resolv.conf
```

### Port Conflicts

```bash
# Check for port conflicts on host
sudo netstat -tulpn | grep LISTEN

# Find which container is using a specific port
docker ps | grep -E '0.0.0.0:80->|:::80->'

# Change port mapping for existing container
docker stop container_id
docker commit container_id new_image
docker run -p 8080:80 new_image
```

## Storage and Volume Issues

### Volume Mount Problems

```bash
# List volumes
docker volume ls

# Inspect volume details
docker volume inspect volume_name

# Check if host path exists for bind mounts
ls -la /host/path/to/mount

# Verify permissions on host directory
ls -la /host/path/to/mount

# Debug by mounting into a temporary container
docker run -it --rm -v volume_name:/data alpine ls -la /data
```

### Disk Space Issues

```bash
# Check Docker disk usage
docker system df -v

# Check available disk space
df -h

# Identify large containers
docker ps -s --sort=size

# Find large images
docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}" | sort -k 2 -h
```

### Cleanup Commands

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune -a --volumes

# Clean up builder cache
docker builder prune
```

## Resource Constraints

### Memory Issues

```bash
# Check container memory usage
docker stats container_id

# Set memory limits
docker run -m 512m image_name

# Check for OOM (Out of Memory) kills
dmesg | grep -i 'killed process'

# View memory stats for a container
docker stats --no-stream container_id
```

### CPU Utilization

```bash
# Check CPU usage
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Limit CPU usage
docker run --cpus=".5" image_name

# Set CPU shares (relative weight)
docker run --cpu-shares=512 image_name
```

### Disk I/O Issues

```bash
# Check container I/O usage
docker stats --format "table {{.Name}}\t{{.BlockIO}}"

# Limit disk I/O
docker run --device-write-bps /dev/sda:1mb image_name
```

## Docker Daemon Issues

### Daemon Won't Start

```bash
# Check Docker service status
systemctl status docker

# View Docker daemon logs
journalctl -u docker.service

# Check Docker daemon configuration
cat /etc/docker/daemon.json

# Start Docker manually with debug output
dockerd --debug
```

### Daemon Performance Issues

```bash
# Check Docker events
docker events

# Monitor Docker daemon resource usage
ps aux | grep docker

# Check Docker info
docker info

# View detailed daemon data
docker system info --format '{{json .}}' | jq
```

## Security Problems

### Container Privilege Issues

```bash
# Check container capabilities
docker inspect --format='{{.HostConfig.CapAdd}}' container_id

# Run container with specific capabilities
docker run --cap-add=NET_ADMIN image_name

# Check if container is running in privileged mode
docker inspect --format='{{.HostConfig.Privileged}}' container_id
```

### Image Vulnerabilities

```bash
# Scan image for vulnerabilities (requires docker scan setup)
docker scan image_name

# Use alternative scanners
# Using Trivy:
trivy image image_name

# Using Clair:
clairctl analyze -l image_name
```

### Access Control

```bash
# List users in a container
docker exec container_id cat /etc/passwd

# Check container user
docker inspect --format='{{.Config.User}}' container_id

# Run container as specific user
docker run -u 1000:1000 image_name
```

## Logging and Debugging

### Log Configuration

```bash
# Check logging driver
docker info --format '{{.LoggingDriver}}'

# Change log driver for a container
docker run --log-driver=json-file --log-opt max-size=10m image_name

# View log configuration
docker inspect --format='{{.HostConfig.LogConfig}}' container_id
```

### Advanced Logging

```bash
# Follow logs in real-time
docker logs -f container_id

# Show logs with timestamps
docker logs -t container_id

# Show logs since specific time
docker logs --since 2023-01-01T10:00:00 container_id

# Show only recent logs
docker logs --tail 100 container_id
```

### Interactive Debugging

```bash
# Enter running container
docker exec -it container_id /bin/bash

# Create a new debugging container that shares namespaces
docker run -it --pid=container:container_id --net=container:container_id --ipc=container:container_id alpine

# Debug with advanced forensic tools
docker run -it --pid=container:container_id --privileged nicolaka/netshoot
```

## Performance Optimization

### Container Performance Analysis

```bash
# View container resource usage
docker stats container_id

# Get detailed container metrics
docker container stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Execute top inside container
docker exec container_id top -b -n 1
```

### Optimizing Container Performance

```bash
# Set CPU priority
docker run --cpu-shares=512 image_name

# Pin container to specific CPUs
docker run --cpuset-cpus="0,1" image_name

# Set memory and swap limits
docker run -m 512m --memory-swap 1g image_name

# Adjust OOM priority
docker run --oom-score-adj=-500 image_name
```

## Cleanup Operations

### Image Cleanup

```bash
# Remove dangling images
docker image prune

# Remove all unused images
docker image prune -a

# Remove images by pattern
docker images | grep pattern | awk '{print $3}' | xargs docker rmi

# Find and remove large images
docker images --format "{{.Size}}\t{{.Repository}}:{{.Tag}}\t{{.ID}}" | sort -h | tail -n 10
```

### Container Cleanup

```bash
# Remove all stopped containers
docker container prune

# Remove containers with specific exit status
docker ps -a | grep Exited | awk '{print $1}' | xargs docker rm

# Stop and remove all containers
docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)

# Remove containers older than 24 hours
docker ps -a --filter "created=24h" -q | xargs docker rm
```

### System-wide Cleanup

```bash
# Show Docker disk usage
docker system df

# Remove all unused objects (containers, networks, images, volumes)
docker system prune -a --volumes

# Run garbage collection on build cache
docker builder prune

# Reclaim space from container logs
sudo sh -c 'truncate -s 0 /var/lib/docker/containers/*/*-json.log'
```

## Real-World Troubleshooting Examples

### Case Study: Container Can't Connect to External Services

**Symptoms:**
- Container can ping IP addresses but can't resolve domain names
- DNS resolution fails inside container

**Diagnosis:**
```bash
# Check DNS settings inside container
docker exec container_id cat /etc/resolv.conf

# Test DNS resolution
docker exec container_id nslookup google.com

# Check Docker DNS settings
docker info | grep -i dns
```

**Solution:**
```bash
# Set explicit DNS for the container
docker run --dns=8.8.8.8 --dns=8.8.4.4 image_name

# Or update Docker daemon settings
# Edit /etc/docker/daemon.json:
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
# Then restart Docker:
sudo systemctl restart docker
```

### Case Study: Container Using Too Much Memory

**Symptoms:**
- Host system becoming unresponsive
- Container being killed unexpectedly
- OOM killer messages in host logs

**Diagnosis:**
```bash
# Check container memory usage
docker stats container_id

# Look for OOM kill messages
dmesg | grep -i 'killed process'

# Check container memory limits
docker inspect --format='{{.HostConfig.Memory}}' container_id
```

**Solution:**
```bash
# Set memory limits for the container
docker run -m 512m --memory-swap 1g image_name

# If application-specific:
# For Java applications, set JVM heap limits
docker run -e JAVA_OPTS='-Xmx256m -Xms128m' java_image

# For Node.js applications
docker run -e NODE_OPTIONS='--max-old-space-size=256' node_image
```

---

Remember that Docker troubleshooting often requires a methodical approach:

1. **Identify the issue**: Check container status, logs, and events
2. **Gather information**: Use inspect, exec, and logs commands
3. **Test hypotheses**: Try simple fixes and validate
4. **Fix root cause**: Apply permanent solutions by updating configurations
5. **Document findings**: Share your solutions to help others

Understanding Docker's architecture and how containers interact with the host system will help you troubleshoot most issues efficiently.