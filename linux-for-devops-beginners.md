# Linux for DevOps Beginners 🐧

Your **comprehensive, hands-on guide** to mastering the Linux fundamentals every DevOps engineer needs — before touching the cloud.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Beginner Friendly](https://img.shields.io/badge/Beginner-Friendly-green.svg)]()

---

## Why This Repo?

**DevOps is built on Linux.** Almost every tool you'll use (Docker, Kubernetes, Terraform, Jenkins, Git) runs primarily on Linux systems. Cloud providers like AWS, Google Cloud, and Azure predominantly use Linux for their services.

This repository provides:
- **Real-world scenarios** you'll encounter as a DevOps engineer
- **Practical exercises** with actual commands and expected outputs  
- **Progressive difficulty** from absolute beginner to job-ready
- **Context** for why each command matters in DevOps workflows

---

## Prerequisites

**Complete Beginners Welcome!** However, you should have:
- Basic computer literacy (file/folder concepts)
- Willingness to use the command line
- About 2-3 hours to work through this guide

**No prior Linux experience required!**

---

## Getting Started

### Step 1: Set Up Your Linux Environment

Choose the option that works best for you:

#### Option A: Local Virtual Machine (Recommended for Beginners)
```bash
# Download VirtualBox: https://www.virtualbox.org/
# Download Ubuntu Desktop: https://ubuntu.com/download/desktop
# Create VM with at least 4GB RAM and 25GB storage
```

#### Option B: Cloud Instance (Great for Real Experience)
```bash
# AWS Free Tier EC2 Instance:
# 1. Create AWS account
# 2. Launch t2.micro Ubuntu 22.04 instance
# 3. Connect via SSH: ssh -i your-key.pem ubuntu@your-ip
```

#### Option C: Windows Subsystem for Linux
```bash
# Run in PowerShell as Administrator:
wsl --install -d Ubuntu
```

#### Option D: macOS Users
```bash
# Your terminal is already Unix-based!
# Most commands work the same
```

### Step 2: Verify Your Setup
Once you have a terminal open, run:
```bash
whoami          # Shows your username
pwd             # Shows current directory
ls              # Lists files in current directory
```

Expected output:
```
$ whoami
your-username
$ pwd
/home/your-username
$ ls
Desktop  Documents  Downloads  ...
```

---

## Learning Path

### Phase 1: Foundation (Start Here)
Master basic navigation and file operations

### Phase 2: File Operations  
Create, modify, and manage files like a pro

### Phase 3: System Monitoring
Understand what's running on your system

### Phase 4: DevOps Essentials
Commands you'll use daily in DevOps work

---

## Phase 1: Foundation Commands

### Navigation & Orientation

#### `pwd` - Print Working Directory
**What it does:** Shows your current location in the file system
```bash
pwd
# Output: /home/username
```
**DevOps Context:** Essential for automation scripts to know their location

#### `ls` - List Directory Contents
**What it does:** Shows files and folders
```bash
ls              # Basic list
ls -l           # Long format with details
ls -la          # Include hidden files (start with .)
ls -lh          # Human-readable file sizes
```

**Real Output Example:**
```bash
$ ls -la
total 28
drwxr-xr-x  7 user user 4096 Jan 15 10:30 .
drwxr-xr-x  3 root root 4096 Jan 10 08:15 ..
-rw-r--r--  1 user user  220 Jan 10 08:15 .bash_logout
-rw-r--r--  1 user user 3771 Jan 10 08:15 .bashrc
drwxr-xr-x  2 user user 4096 Jan 15 09:45 Documents
-rwxr-xr-x  1 user user 1337 Jan 15 10:30 deploy.sh
```

**DevOps Context:** Checking deployment files, config files, logs

#### `cd` - Change Directory  
**What it does:** Navigate between folders
```bash
cd /var/log           # Go to specific path
cd ..                 # Go up one level
cd ~                  # Go to home directory
cd -                  # Go to previous directory
```

**Pro Tips:**
- Use Tab key for autocompletion
- `cd` without arguments takes you home
- `cd -` toggles between last two directories

### 🔍 **Practice Exercise 1.1: Basic Navigation**
```bash
# Try these commands in sequence:
pwd                    # Note your starting location
ls -l                  # See what's in current directory
cd /                   # Go to root directory
pwd                    # Confirm you're at root (/)
ls -l                  # See root directory contents
cd ~                   # Return home
pwd                    # Confirm you're back home
```

---

## 📄 Phase 2: File Operations

### Viewing File Contents

#### `cat` - Display Entire File
```bash
cat filename.txt       # Show entire file
cat file1.txt file2.txt # Show multiple files
```
**When to use:** Small files, quick content checks

#### `less` - Paginated File Viewer
```bash
less filename.txt      # Navigate with arrow keys, 'q' to quit
```
**Navigation in less:**
- `Space` or `Page Down` - Next page
- `b` or `Page Up` - Previous page  
- `/search-term` - Search forward
- `q` - Quit

**When to use:** Large files, log files

#### `head` & `tail` - Show Beginning/End of Files
```bash
head -10 app.log       # First 10 lines
tail -20 app.log       # Last 20 lines
tail -f app.log        # Follow live updates (Ctrl+C to stop)
```

**DevOps Context:** `tail -f` is crucial for monitoring live application logs

### Creating and Editing Files

#### `touch` - Create Empty Files
```bash
touch newfile.txt      # Create empty file
touch file1.txt file2.txt file3.txt  # Create multiple files
```

#### `nano` - Simple Text Editor
```bash
nano filename.txt      # Open file for editing
```
**nano shortcuts:**
- `Ctrl+O` - Save file
- `Ctrl+X` - Exit
- `Ctrl+K` - Delete line

#### `echo` - Display Text / Create Simple Files
```bash
echo "Hello World"                    # Display text
echo "Hello World" > newfile.txt      # Create file with content
echo "More content" >> newfile.txt    # Append to file
```

### File Operations

#### `cp` - Copy Files
```bash
cp source.txt destination.txt         # Copy file
cp -r folder1/ folder2/              # Copy directory recursively
cp *.txt backup/                     # Copy all .txt files
```

#### `mv` - Move/Rename Files
```bash
mv oldname.txt newname.txt           # Rename file
mv file.txt /path/to/directory/      # Move file
mv *.log logs/                       # Move all .log files
```

#### `rm` - Remove Files
```bash
rm filename.txt                      # Delete file
rm -r directory/                     # Delete directory recursively
rm -f filename.txt                   # Force delete (no confirmation)
```

**⚠️ WARNING:** `rm` is permanent! There's no "trash" in Linux. Be very careful with `rm -rf`

### 🔍 **Practice Exercise 2.1: File Management**
```bash
# Create a project structure
mkdir -p my-project/{src,tests,docs}
cd my-project

# Create some files
echo "# My Project" > README.md
echo "print('Hello World')" > src/app.py
echo "Test file" > tests/test_app.py

# View the structure
ls -la
tree .  # (if tree is installed)

# Practice viewing files
cat README.md
echo "More info" >> README.md
cat README.md

# Practice copying and moving
cp README.md docs/
mv src/app.py src/main.py
ls -la src/
```

---

##  Phase 3: Search and Filter

### `grep` - Pattern Matching
**What it does:** Search for text patterns in files
```bash
grep "ERROR" app.log                 # Find lines containing "ERROR"
grep -i "error" app.log              # Case-insensitive search
grep -n "ERROR" app.log              # Show line numbers
grep -r "TODO" .                     # Search recursively in all files
grep -v "INFO" app.log               # Show lines NOT containing "INFO"
```

**Real DevOps Example:**
```bash
# Find all failed API calls in nginx logs
grep "HTTP/1.1\" 5" /var/log/nginx/access.log

# Find all error logs from today
grep "$(date +%Y-%m-%d)" /var/log/syslog | grep -i error
```

### `find` - Locate Files and Directories
```bash
find /path -name "filename"          # Find by exact name
find /path -name "*.log"             # Find by pattern
find /path -type f                   # Find only files
find /path -type d                   # Find only directories
find /path -size +100M               # Find files larger than 100MB
find /path -mtime -7                 # Find files modified in last 7 days
```

**DevOps Examples:**
```bash
# Find all Docker-related files
find / -name "*docker*" 2>/dev/null

# Find large log files taking up space
find /var/log -name "*.log" -size +50M

# Find recently modified config files
find /etc -name "*.conf" -mtime -1
```

### 🔍 **Practice Exercise 3.1: Search and Filter**
```bash
# Create sample log file
echo "2024-01-15 10:30:01 INFO User login successful" > app.log
echo "2024-01-15 10:30:45 ERROR Database connection failed" >> app.log
echo "2024-01-15 10:31:12 INFO User profile updated" >> app.log
echo "2024-01-15 10:31:33 ERROR Payment processing failed" >> app.log
echo "2024-01-15 10:32:01 WARNING High memory usage detected" >> app.log

# Practice grep
grep "ERROR" app.log
grep -c "ERROR" app.log              # Count ERROR lines
grep -n "INFO" app.log               # Show line numbers

# Practice find
find . -name "*.log"
find . -type f -exec grep -l "ERROR" {} \;
```

---

##  Phase 4: System Monitoring (DevOps Essentials)

### Process Management

#### `ps` - Show Running Processes
```bash
ps                     # Show processes for current user
ps aux                 # Show all processes (most common)
ps aux | grep nginx    # Find specific process
```

**Output explanation:**
```bash
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      1234  0.1  2.3 123456  7890 ?        Sl   10:30   0:05 /usr/bin/nginx
```
- **PID:** Process ID (use this to kill processes)
- **%CPU:** CPU usage percentage
- **%MEM:** Memory usage percentage

#### `top` - Live System Monitor
```bash
top                    # Live view of processes
htop                   # Enhanced version (if installed)
```

**top shortcuts:**
- `q` - Quit
- `k` - Kill process (enter PID)
- `M` - Sort by memory usage
- `P` - Sort by CPU usage

#### `kill` - Terminate Processes
```bash
kill 1234              # Gracefully stop process with PID 1234
kill -9 1234           # Force kill process
killall nginx          # Kill all nginx processes
```

### System Information

#### `df` - Disk Space Usage
```bash
df -h                  # Human-readable disk usage
df -h /                # Check root partition
```

#### `du` - Directory Size
```bash
du -h /var/log         # Size of /var/log directory
du -sh *               # Size of each item in current directory
du -sh /var/log/*.log | sort -hr  # Largest log files first
```

#### `free` - Memory Usage
```bash
free -h                # Memory usage in human-readable format
```

###  **Practice Exercise 4.1: System Monitoring**
```bash
# Check what's running
ps aux | head -10

# Monitor system resources
top                    # Press 'q' to quit

# Check disk space
df -h

# Find memory-hungry processes
ps aux --sort=-%mem | head -10

# Check which directories use most space
du -sh /var/* 2>/dev/null | sort -hr
```

---

## Networking Essentials

### `curl` - HTTP Client
**What it does:** Make HTTP requests, test APIs
```bash
curl https://httpbin.org/ip           # Simple GET request
curl -I https://google.com            # Headers only
curl -X POST -d "data" https://api.example.com  # POST request
curl -o file.html https://example.com # Save response to file
```

**DevOps Context:** Testing API endpoints, downloading files, health checks

### `ping` - Test Network Connectivity
```bash
ping google.com                       # Test basic connectivity
ping -c 4 8.8.8.8                    # Send only 4 packets
```

### `wget` - Download Files
```bash
wget https://example.com/file.zip     # Download file
wget -r -np -k https://example.com/   # Mirror website
```

---

## 🔐 Permissions and Ownership

### Understanding Permissions
Linux permissions have three levels:
- **Owner** (u): The user who owns the file
- **Group** (g): Users in the file's group  
- **Others** (o): Everyone else

Three permission types:
- **Read** (r): View file contents / list directory
- **Write** (w): Modify file / create files in directory
- **Execute** (x): Run file / enter directory

### `chmod` - Change Permissions
```bash
chmod +x script.sh     # Make file executable
chmod 755 script.sh    # rwxr-xr-x (owner: rwx, group: r-x, others: r-x)
chmod 644 file.txt     # rw-r--r-- (owner: rw-, group: r--, others: r--)
```

**Common permissions:**
- `755` - Executable files (scripts, programs)
- `644` - Regular files (documents, configs)
- `600` - Private files (SSH keys, passwords)

### `chown` - Change Ownership
```bash
chown user:group file.txt             # Change user and group
chown user file.txt                   # Change user only
chown :group file.txt                 # Change group only
sudo chown -R www-data:www-data /var/www/  # Recursive change
```

---

##  Real DevOps Scenarios

### Scenario 1: Troubleshooting a Web Server
**Situation:** Your web application is down. Users can't access the site.

**Step-by-Step Investigation:**
```bash
# 1. Check if the web server process is running
ps aux | grep nginx
# or
ps aux | grep apache2

# 2. If not running, check the logs
tail -50 /var/log/nginx/error.log

# 3. Check disk space (common cause of failures)
df -h

# 4. Check memory usage
free -h

# 5. Try to restart the service
sudo systemctl status nginx
sudo systemctl restart nginx

# 6. Verify it's working
curl -I http://localhost
```

### Scenario 2: Investigating High CPU Usage
**Situation:** Your server is running slowly.

```bash
# 1. Check current CPU usage
top

# 2. Find the most CPU-intensive processes
ps aux --sort=-%cpu | head -10

# 3. Check system load
uptime

# 4. Investigate specific process
ps -p <PID> -o pid,ppid,cmd,%mem,%cpu

# 5. Check for any runaway processes
ps aux | grep -v " 0.0 "
```

### Scenario 3: Log Analysis for Security
**Situation:** Investigate potential security breach.

```bash
# 1. Check failed login attempts
grep "Failed password" /var/log/auth.log

# 2. Look for suspicious IP addresses
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr

# 3. Check recent user activity
last -10

# 4. Look for unusual processes
ps aux | grep -v '^root\|^daemon\|^www-data'

# 5. Check network connections
netstat -tulpn
```

### Scenario 4: Disk Space Crisis
**Situation:** Server is running out of disk space.

```bash
# 1. Check overall disk usage
df -h

# 2. Find which directories are using the most space
du -sh /* 2>/dev/null | sort -hr

# 3. Find large files
find / -size +100M -type f 2>/dev/null

# 4. Check log file sizes
du -sh /var/log/* | sort -hr

# 5. Clean up old logs (be careful!)
find /var/log -name "*.log" -mtime +30 -exec ls -lh {} \;
```

---

##  Common Beginner Mistakes & How to Avoid Them

### 1. Using `rm -rf` Without Double-Checking
**Mistake:** `rm -rf /important/directory`
**Solution:** Always use `ls` first to verify what you're about to delete
```bash
# Instead of immediately deleting:
ls -la /path/to/directory  # Verify contents first
rm -rf /path/to/directory  # Then delete
```

### 2. Running Commands as Root Unnecessarily
**Mistake:** `sudo rm -rf /var/*`
**Solution:** Only use `sudo` when necessary, understand what the command does
```bash
# Check if you really need sudo:
whoami  # Check current user
id      # Check current permissions
```

### 3. Not Understanding File Paths
**Mistake:** Confusing relative vs absolute paths
**Solution:** 
- Absolute paths start with `/` (e.g., `/home/user/file.txt`)
- Relative paths don't (e.g., `../file.txt` or `file.txt`)
```bash
pwd     # Always know where you are
```

### 4. Ignoring File Permissions
**Mistake:** `./script.sh: Permission denied`
**Solution:** Make scripts executable
```bash
ls -l script.sh          # Check current permissions
chmod +x script.sh       # Make executable
./script.sh             # Now it works
```

---

##  Essential Commands Cheat Sheet

### Navigation
| Command | Description | Example |
|---------|-------------|---------|
| `pwd` | Show current directory | `pwd` |
| `ls -la` | List all files with details | `ls -la /home` |
| `cd` | Change directory | `cd /var/log` |
| `cd ..` | Go up one level | `cd ..` |
| `cd ~` | Go to home directory | `cd ~` |

### File Operations  
| Command | Description | Example |
|---------|-------------|---------|
| `cat` | Display file contents | `cat app.log` |
| `less` | View file page by page | `less app.log` |
| `tail -f` | Follow live log updates | `tail -f /var/log/syslog` |
| `grep` | Search text in files | `grep "ERROR" app.log` |
| `find` | Find files/directories | `find /var -name "*.log"` |

### System Monitoring
| Command | Description | Example |
|---------|-------------|---------|
| `ps aux` | Show all processes | `ps aux \| grep nginx` |
| `top` | Live process monitor | `top` |
| `df -h` | Check disk space | `df -h` |
| `free -h` | Check memory usage | `free -h` |
| `du -sh` | Check directory size | `du -sh /var/log` |

### Process Management
| Command | Description | Example |
|---------|-------------|---------|
| `kill PID` | Stop process gracefully | `kill 1234` |
| `kill -9 PID` | Force kill process | `kill -9 1234` |
| `killall` | Kill all processes by name | `killall nginx` |

### Networking
| Command | Description | Example |
|---------|-------------|---------|
| `curl` | Make HTTP requests | `curl -I https://google.com` |
| `ping` | Test connectivity | `ping -c 4 8.8.8.8` |
| `wget` | Download files | `wget https://example.com/file.zip` |

---

## Next Steps & Advanced Topics

Once you're comfortable with these basics, explore:

### Intermediate Topics
- **Shell Scripting:** Automate repetitive tasks
- **Text Processing:** `awk`, `sed`, advanced `grep`
- **System Services:** `systemctl`, service management
- **Environment Variables:** `export`, `.bashrc`, `.profile`
- **Package Management:** `apt`, `yum`, `dnf`

### DevOps-Specific Skills
- **Docker:** Containerization fundamentals
- **Git:** Version control for code and infrastructure
- **SSH:** Secure remote server management
- **Cron Jobs:** Automated task scheduling
- **Log Management:** `journalctl`, `rsyslog`

### Advanced Linux
- **Performance Tuning:** `iostat`, `vmstat`, `sar`
- **Security:** `iptables`, `fail2ban`, user management
- **Storage Management:** LVM, disk partitioning
- **Networking:** Advanced networking concepts

---

##  Recommended Resources

### Practice Platforms
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) - Linux challenges
- [Linux Journey](https://linuxjourney.com/) - Interactive lessons
- [Vim Adventures](https://vim-adventures.com/) - Learn Vim through a game

### Documentation
- [Linux Command Library](https://linuxcommandlibrary.com/) - Comprehensive command reference
- [ExplainShell](https://explainshell.com/) - Break down complex commands
- [TLDR Pages](https://tldr.sh/) - Simplified man pages

### Books
- "The Linux Command Line" by William Shotts
- "Unix and Linux System Administration Handbook"
- "Linux Administration: A Beginner's Guide"

---

## 🤝 Contributing

Found an error? Have a suggestion? Want to add a scenario?

1. Fork this repository
2. Create a feature branch: `git checkout -b improve-readme`
3. Make your changes
4. Submit a pull request

### Contribution Guidelines
- Keep examples practical and DevOps-focused
- Test all commands before submitting
- Use clear, beginner-friendly explanations
- Include expected outputs when helpful

---

##  License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

##  Author

**Osomudeya Zudonu**
- GitHub: https://github.com/Osomudeya
- LinkedIn: https://www.linkedin.com/in/osomudeya-zudonu-17290b124/)
- Email: 

---

##  Acknowledgments

- Linux community for excellent documentation
- DevOps practitioners who shared real-world scenarios
- All contributors who helped improve this guide

---

**Ready to become a Linux power user?** Start with Phase 1 and work your way through each section. Remember: the best way to learn Linux is by using it!

**Questions?** Open an issue or reach out on social media. Happy learning!
