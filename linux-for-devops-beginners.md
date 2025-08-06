# Linux for DevOps Beginners 🐧

Your **hands-on guide** to mastering the Linux fundamentals every DevOps engineer needs — before touching the cloud.

## 🚀 Why This Repo?
Almost all DevOps tools (Docker, Kubernetes, Terraform) run on Linux. This repo gives you **practical, real-world scenarios** to learn essential commands fast.

---

## 📦 Getting Started

### 1. Spin Up a Linux Environment
Choose one:
- **Local VM:** [VirtualBox + Ubuntu](https://ubuntu.com/download/desktop)
- **Cloud:** AWS Free Tier → EC2 Ubuntu instance  
- **Windows:** [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install)

---

## 📚 Core Commands by Use Case

### **Navigation**
- `pwd` → Show current directory  
- `ls -l` → List files with details  
- `cd /path/to/folder` → Change directory  

### **File Viewing**
- `cat file.txt` → View file contents  
- `less file.txt` → Scroll through file  
- `tail -f app.log` → Live log stream  

### **Process Management**
- `ps aux | grep nginx` → Find a process  
- `top` → View live system usage  
- `kill <PID>` → End a process  

### **Search**
- `grep ERROR app.log` → Find "ERROR" in logs  
- `find /var/log -name "*.log"` → Locate log files  

### **Permissions**
- `chmod +x script.sh` → Make file executable  
- `chown user:group file.txt` → Change ownership  

### **Networking**
- `curl https://example.com` → Test an endpoint  
- `ping google.com` → Test connectivity  

---

## 🔹 Practice Scenarios

### 1. Navigation & Files
- Move to `/var/log`  
- List files in long format  
- Find and open `syslog`

### 2. Monitoring Logs
- Tail a log file and watch updates live  
- Search for the word "ERROR" in logs

### 3. Processes
- Find and restart a process  
- Monitor CPU usage

### 4. Networking
- Test if an API endpoint is reachable with `curl`  
- Verify server connectivity with `ping`

---

## 📄 Cheat Sheet
Grab the **Linux Command Cheat Sheet (PDF)** here → *[Download Link Coming Soon]*

---

## 🤝 Contribute
Got a useful Linux scenario? PRs welcome!

---

**Author:** [Your Name](https://github.com/YourUsername)
