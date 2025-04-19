# Linux CPU Troubleshooting Commands

This document provides a comprehensive collection of commands for diagnosing and resolving CPU-related issues in Linux environments.

## Table of Contents

- [Quick CPU Status](#quick-cpu-status)
- [Detailed CPU Information](#detailed-cpu-information)
- [CPU Load Monitoring](#cpu-load-monitoring)
- [Process CPU Usage](#process-cpu-usage)
- [CPU Throttling](#cpu-throttling)
- [CPU Performance Tuning](#cpu-performance-tuning)
- [Common Issues and Solutions](#common-issues-and-solutions)

## Quick CPU Status

### Basic CPU Information

```bash
# Show CPU model and basic information
lscpu

# Display number of processing units
nproc

# Show CPU information from /proc/cpuinfo
cat /proc/cpuinfo
```

### CPU Load Average

```bash
# Quick overview of system load (1, 5, and 15-minute averages)
uptime

# Output:
# 14:23:45 up 23 days, 5:32, 3 users, load average: 1.05, 0.70, 0.48
```

The three numbers represent the system load average over 1, 5, and 15 minutes. Values below your CPU core count generally indicate the system is handling the load well.

## Detailed CPU Information

### CPU Architecture and Features

```bash
# Detailed CPU information including cache sizes and supported features
lscpu -e

# Show CPU topology
lstopo
```

### CPU Frequency Information

```bash
# Check current CPU frequency
cat /proc/cpuinfo | grep MHz

# Check CPU scaling governors and available frequencies
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_available_frequencies
```

## CPU Load Monitoring

### Real-time CPU Usage

```bash
# Monitor CPU usage in real-time (updates every 3 seconds)
top

# More user-friendly alternative to top
htop

# Focused CPU statistics with color highlighting
mpstat -P ALL 2

# CPU statistics with timestamp
sar -u 2 10
```

### Graphical Output in Terminal

```bash
# Visual CPU load graph in terminal (may need installation)
s-tui

# Simple ASCII graph of CPU usage
dstat -c
```

## Process CPU Usage

### Finding CPU-Intensive Processes

```bash
# Sort processes by CPU usage
ps aux --sort=-%cpu | head -10

# Monitor processes and sort by CPU usage in real-time
top -o %CPU

# Check which processes are causing CPU load
pidstat 1
```

### Process-Specific Investigation

```bash
# Analyze specific process CPU usage
pidstat -p PID 1

# Check what a process is doing
strace -p PID -c

# See which system calls are being made
strace -p PID
```

## CPU Throttling

### Check for Thermal Throttling

```bash
# Install and run thermald to check CPU temperature
sudo apt install thermald
systemctl status thermald

# Check CPU temperature
sensors | grep Core

# Check for throttling events
dmesg | grep -i throttling
```

### Power-Related Throttling

```bash
# Check if CPU power management is limiting performance
sudo turbostat --Summary --quiet --show Busy%,Bzy_MHz,PkgWatt,PkgTmp,RAMWatt,GFXWatt

# Check Intel P-state driver status (Intel CPUs)
cat /sys/devices/system/cpu/intel_pstate/status
```

## CPU Performance Tuning

### CPU Governor Settings

```bash
# List available CPU governors
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Set performance governor (temporary)
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Make performance governor setting permanent
sudo apt install cpufrequtils
sudo cpufreq-set -r -g performance
```

### Process Priority

```bash
# Change process priority (niceness)
renice -n -5 -p PID

# Start a process with higher priority
nice -n -10 command
```

## Common Issues and Solutions

### High Load Average with Low CPU Usage

This typically indicates I/O bottlenecks or processes waiting for resources.

```bash
# Check for I/O wait
iostat -xz 1

# Check for processes in uninterruptible sleep (D state)
ps aux | awk '$8 ~ /D/ { print $0 }'
```

### Single Core Overloaded

This often happens with single-threaded applications.

**Solution:**
```bash
# Set CPU affinity to distribute load
taskset -pc 0-3 PID

# Check current CPU affinity
taskset -pc PID
```

### Zombie Processes Consuming CPU

```bash
# Find zombie processes
ps aux | grep Z

# Find parent of zombie process
ps -o ppid= <zombie_pid>

# Restart the parent process to clean up zombies
kill -HUP <parent_pid>
```

### System Unresponsive Due to CPU Load

If the system becomes unresponsive due to CPU overload, you can use the Magic SysRq key to help recover:

```bash
# Enable SysRq if not already enabled
echo 1 | sudo tee /proc/sys/kernel/sysrq

# Kill the most intensive process
sudo alt + sysrq + f

# Emergency sync to disk
sudo alt + sysrq + s

# Emergency remount read-only
sudo alt + sysrq + u

# Emergency reboot
sudo alt + sysrq + b
```

## Additional Resources

- [Linux Performance](http://www.brendangregg.com/linuxperf.html) by Brendan Gregg
- [Linux Performance Analysis in 60 Seconds](https://netflixtechblog.com/linux-performance-analysis-in-60-000-milliseconds-accc10403c55)
- [Red Hat Performance Tuning Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/index)

---

**Note:** Some commands may require installation of additional packages or root privileges. Always understand what a command does before executing it, especially in production environments.