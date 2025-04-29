# Prometheus and Grafana Troubleshooting Guide

This comprehensive guide provides commands, techniques, and solutions for troubleshooting Prometheus monitoring systems and Grafana dashboards in DevOps environments.

## Table of Contents

- [Prometheus Server Issues](#prometheus-server-issues)
- [Prometheus Target Discovery](#prometheus-target-discovery)
- [Prometheus Alerting Issues](#prometheus-alerting-issues)
- [PromQL Troubleshooting](#promql-troubleshooting)
- [Prometheus Storage and Performance](#prometheus-storage-and-performance)
- [Prometheus Exporters](#prometheus-exporters)
- [Grafana Connection Issues](#grafana-connection-issues)
- [Grafana Dashboard Problems](#grafana-dashboard-problems)
- [Grafana Authentication Issues](#grafana-authentication-issues)
- [Grafana Alerting](#grafana-alerting)
- [Complete System Health Check](#complete-system-health-check)

## Prometheus Server Issues

### Prometheus Service Startup Problems

```bash
# Check Prometheus service status
sudo systemctl status prometheus

# View Prometheus logs
sudo journalctl -u prometheus -f

# Verify Prometheus configuration
promtool check config /etc/prometheus/prometheus.yml

# Test Prometheus configuration file
prometheus --test --config.file=/etc/prometheus/prometheus.yml

# Check if Prometheus is running
ps aux | grep prometheus
```

### Configuration Validation

```bash
# Validate configuration file
promtool check config /etc/prometheus/prometheus.yml

# Validate rules file
promtool check rules /etc/prometheus/rules/*.yml

# Validate alerting rules
promtool check alerts /etc/prometheus/alerts/*.yml

# Test configuration and exit
prometheus --config.file=/etc/prometheus/prometheus.yml --web.enable-lifecycle --web.enable-admin-api --test
```

### Common Configuration Issues

1. **Invalid YAML syntax**
   ```bash
   # Use YAML linter to check syntax
   yamllint /etc/prometheus/prometheus.yml
   ```

2. **Permission problems**
   ```bash
   # Check Prometheus user permissions
   sudo -u prometheus ls -la /etc/prometheus/
   sudo -u prometheus ls -la /var/lib/prometheus/
   ```

3. **Certificate issues for TLS**
   ```bash
   # Verify TLS certificates
   openssl x509 -in /etc/prometheus/cert.pem -text -noout
   ```

## Prometheus Target Discovery

### Target Status Inspection

```bash
# API endpoint for targets
curl -s http://localhost:9090/api/v1/targets | jq .

# Filter for specific target status
curl -s 'http://localhost:9090/api/v1/targets?state=down' | jq .

# Check service discovery configs
curl -s http://localhost:9090/api/v1/targets/metadata | jq .
```

### Target Connection Issues

1. **Network connectivity**
   ```bash
   # Check connectivity to target
   curl -v http://target:port/metrics
   telnet target port
   ```

2. **Authentication issues**
   ```bash
   # Test with authentication
   curl -v -u username:password http://target:port/metrics
   ```

3. **TLS/SSL problems**
   ```bash
   # Test with TLS
   curl -v --cert /path/to/cert.pem --key /path/to/key.pem https://target:port/metrics
   
   # Skip verification for testing
   curl -v -k https://target:port/metrics
   ```

### Kubernetes Service Discovery Issues

```bash
# Check RBAC permissions
kubectl auth can-i list pods --as=system:serviceaccount:monitoring:prometheus

# Inspect service discovery annotations
kubectl get pods -n app-namespace -o jsonpath='{.items[*].metadata.annotations}'

# Verify endpoints existence
kubectl get endpoints -n app-namespace
```

## Prometheus Alerting Issues

### AlertManager Status

```bash
# Check AlertManager service status
sudo systemctl status alertmanager

# View AlertManager logs
sudo journalctl -u alertmanager -f

# Verify AlertManager configuration
amtool check-config /etc/alertmanager/alertmanager.yml

# Check active alerts
curl -s http://localhost:9093/api/v1/alerts | jq .
```

### Testing Alert Rules

```bash
# Check alert rules syntax
promtool check rules /etc/prometheus/rules/*.yml

# Test alert rule expression
curl -s --data-urlencode 'query=ALERTS{alertstate="firing"}' http://localhost:9090/api/v1/query | jq .

# Manually fire a test alert
amtool alert add alertname="TestAlert" severity="critical" instance="test" job="test"
```

### Notification Problems

1. **Email notification issues**
   ```bash
   # Test SMTP connection
   nc -zv smtp.example.com 25
   
   # Send test email
   echo -e "Subject: Test Email\r\n\r\nTest Body" | curl --ssl smtp://smtp.example.com:25 --mail-from alert@example.com --mail-rcpt admin@example.com -T -
   ```

2. **Slack notification issues**
   ```bash
   # Test Slack webhook
   curl -X POST -H 'Content-type: application/json' --data '{"text":"Test Alert"}' https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
   ```

3. **PagerDuty notification issues**
   ```bash
   # Test PagerDuty API
   curl -H "Content-type: application/json" -X POST -d '{"routing_key":"YOUR_INTEGRATION_KEY","event_action":"trigger","payload":{"summary":"Test alert","source":"manual test","severity":"critical"}}' "https://events.pagerduty.com/v2/enqueue"
   ```

## PromQL Troubleshooting

### Testing PromQL Expressions

```bash
# Basic query
curl -s --data-urlencode 'query=up' http://localhost:9090/api/v1/query | jq .

# Range query
curl -s --data-urlencode 'query=rate(node_cpu_seconds_total{mode="user"}[5m])' --data-urlencode 'start=2023-01-01T00:00:00Z' --data-urlencode 'end=2023-01-01T01:00:00Z' --data-urlencode 'step=15s' http://localhost:9090/api/v1/query_range | jq .

# Debug expression with metadata
curl -s http://localhost:9090/api/v1/metadata?metric=node_cpu_seconds_total | jq .
```

### Common PromQL Mistakes

1. **Rate used with gauge metrics**
   ```bash
   # Incorrect (using rate with gauge)
   rate(node_memory_MemFree_bytes[5m])
   
   # Correct (using gauge directly)
   node_memory_MemFree_bytes
   ```

2. **Missing selector in aggregation**
   ```bash
   # May return unexpected results
   sum(rate(http_requests_total[5m]))
   
   # Specify what to aggregate by
   sum by(instance, job) (rate(http_requests_total[5m]))
   ```

3. **Incorrect time range**
   ```bash
   # For sparse metrics, increase range
   rate(rare_event_counter[5m]) # might be empty
   rate(rare_event_counter[1h]) # better for sparse metrics
   ```

## Prometheus Storage and Performance

### Storage Issues

```bash
# Check disk space
df -h /var/lib/prometheus/

# Check TSDB stats
curl -s http://localhost:9090/api/v1/status/tsdb | jq .

# Get storage warnings
curl -s http://localhost:9090/api/v1/status/runtimeinfo | jq .

# Check compaction status
curl -s http://localhost:9090/api/v1/status/buildinfo | jq .
```

### Performance Troubleshooting

```bash
# Get runtime metrics
curl -s http://localhost:9090/metrics | grep prometheus_engine_ | sort

# Check query performance
curl -s http://localhost:9090/api/v1/query_exemplars?query=prometheus_engine_query_duration_seconds

# Memory usage stats
curl -s http://localhost:9090/metrics | grep process_resident_memory_bytes

# Sample scrape duration
curl -s http://localhost:9090/metrics | grep prometheus_target_scrape_duration_seconds
```

### Optimizing Prometheus

1. **Adjust storage retention**
   ```bash
   # Modify retention period (in prometheus.yml)
   storage:
     tsdb:
       retention.time: 15d
       
   # Apply changes without restart
   curl -X POST http://localhost:9090/-/reload
   ```

2. **Adjust scrape intervals**
   ```bash
   # In prometheus.yml
   global:
     scrape_interval: 30s  # Increase for less storage usage
     
   # For specific targets
   scrape_configs:
     - job_name: 'high-frequency'
       scrape_interval: 5s
       static_configs:
         - targets: ['critical:9100']
   ```

3. **Use external storage**
   ```bash
   # Configure remote write
   prometheus.yml:
   remote_write:
     - url: "http://remote-storage:9201/write"
   ```

## Prometheus Exporters

### Node Exporter Issues

```bash
# Check Node Exporter status
sudo systemctl status node_exporter

# View Node Exporter logs
sudo journalctl -u node_exporter -f

# Test metrics endpoint
curl http://localhost:9100/metrics

# Check enabled collectors
ps aux | grep node_exporter | grep collector
```

### Custom Exporter Debugging

```bash
# Check if exporter is running
ps aux | grep exporter

# Test metrics endpoint
curl http://localhost:port/metrics

# Follow exporter logs
tail -f /var/log/exporter.log

# Check port availability
netstat -tulpn | grep port
```

### Blackbox Exporter Issues

```bash
# Test specific probe
curl 'http://localhost:9115/probe?target=https://example.com&module=http_2xx'

# Check configuration
cat /etc/prometheus/blackbox.yml

# Validate configuration
blackbox_exporter --config.check --config.file=/etc/prometheus/blackbox.yml
```

## Grafana Connection Issues

### Grafana Server Startup Problems

```bash
# Check Grafana service status
sudo systemctl status grafana-server

# View Grafana logs
sudo journalctl -u grafana-server -f
tail -f /var/log/grafana/grafana.log

# Verify Grafana configuration
cat /etc/grafana/grafana.ini

# Check if Grafana is running
ps aux | grep grafana
```

### Datasource Connection Issues

```bash
# Test Prometheus connection
curl -v http://prometheus:9090/api/v1/query?query=up

# Check network connectivity from Grafana server
nc -zv prometheus-host 9090

# Test with HTTPie (more readable output)
http GET http://prometheus:9090/api/v1/query?query=up

# Check Grafana datasource configuration
curl -s -H "Authorization: Bearer admin:admin" http://localhost:3000/api/datasources | jq .
```

### Common Connection Problems

1. **CORS issues**
   ```bash
   # In prometheus.yml
   web:
     cors:
       access-control-allow-origin: '*'
   ```

2. **Authentication problems**
   ```bash
   # Test with basic auth
   curl -v -u username:password http://prometheus:9090/api/v1/query?query=up
   ```

3. **TLS certificate issues**
   ```bash
   # Test TLS connection
   openssl s_client -connect prometheus-host:9090
   ```

## Grafana Dashboard Problems

### Dashboard Loading Issues

```bash
# Check browser console for errors (F12 in most browsers)

# Verify Grafana API response
curl -s -H "Authorization: Bearer admin:admin" http://localhost:3000/api/dashboards/uid/dashboard-uid | jq .

# Check for database issues
sudo -u grafana psql -h localhost -U grafana -d grafana -c "SELECT * FROM dashboard LIMIT 1;"
```

### Panel Rendering Problems

```bash
# Check renderer (if using image rendering)
sudo systemctl status grafana-renderer

# Check renderer logs
sudo journalctl -u grafana-renderer -f

# Test direct query to Prometheus
curl -s --data-urlencode 'query=up' http://prometheus:9090/api/v1/query | jq .
```

### Query Performance Issues

```bash
# Enable query logging (in grafana.ini)
[log]
filters = rendering:debug query:debug

# Review slow query logs
grep "slow query" /var/log/grafana/grafana.log

# Optimize Prometheus queries
# - Use recording rules for complex queries
# - Limit time range
# - Reduce number of series (use labels wisely)
```

## Grafana Authentication Issues

### Login Problems

```bash
# Check auth settings
grep "auth" /etc/grafana/grafana.ini

# Verify LDAP configuration
cat /etc/grafana/ldap.toml

# Test LDAP connection
ldapsearch -x -H ldap://ldap-server:389 -D "cn=admin,dc=example,dc=com" -w password -b "dc=example,dc=com" "(uid=username)"

# Check Grafana auth logs
grep "logger=auth" /var/log/grafana/grafana.log
```

### User Permission Issues

```bash
# List users
curl -s -H "Authorization: Bearer admin:admin" http://localhost:3000/api/users | jq .

# Check user organizations
curl -s -H "Authorization: Bearer admin:admin" http://localhost:3000/api/users/1/orgs | jq .

# Check user permissions
curl -s -H "Authorization: Bearer admin:admin" http://localhost:3000/api/user/permissions | jq .
```

### Reset Admin Password

```bash
# CLI reset (Grafana 8+)
grafana-cli admin reset-admin-password newpassword

# SQLite database
sqlite3 /var/lib/grafana/grafana.db "UPDATE user SET password = '59acf18b94d7eb0694c61e60ce44c110c7a683ac6a8f09580d626f90f4a242000746579358d77dd9e570e83fa24faa88a8a6', salt = 'F3FAxVm33R' WHERE login = 'admin'"

# PostgreSQL database
sudo -u grafana psql -h localhost -U grafana -d grafana -c "UPDATE \"user\" SET password = '59acf18b94d7eb0694c61e60ce44c110c7a683ac6a8f09580d626f90f4a242000746579358d77dd9e570e83fa24faa88a8a6', salt = 'F3FAxVm33R' WHERE login = 'admin';"
```

## Grafana Alerting

### Alert Rule Issues

```bash
# List alert rules (Grafana 8+)
curl -s -H "Authorization: Bearer admin:admin" http://localhost:3000/api/ruler/grafana/api/v1/rules | jq .

# Check alert instances
curl -s -H "Authorization: Bearer admin:admin" http://localhost:3000/api/alertmanager/grafana/api/v2/alerts | jq .

# View alert state history
curl -s -H "Authorization: Bearer admin:admin" http://localhost:3000/api/annotations?limit=100 | jq .
```

### Notification Channel Problems

```bash
# List notification channels
curl -s -H "Authorization: Bearer admin:admin" http://localhost:3000/api/alert-notifications | jq .

# Test notification channel
curl -X POST -H "Authorization: Bearer admin:admin" -H "Content-Type: application/json" -d '{"type":"email"}' http://localhost:3000/api/alert-notifications/test | jq .

# Check alerting logs
grep "alerting" /var/log/grafana/grafana.log
```

## Complete System Health Check

### End-to-End Monitoring Pipeline Test

1. **Generate test metrics**
   ```bash
   # Create test exporter (using Node.js)
   const http = require('http');
   const server = http.createServer((req, res) => {
     res.writeHead(200, {'Content-Type': 'text/plain'});
     res.end(`# HELP test_metric A test metric\n# TYPE test_metric gauge\ntest_metric{label="test"} ${Math.random() * 100}\n`);
   });
   server.listen(8099);
   
   # Or with Python
   from http.server import HTTPServer, BaseHTTPRequestHandler
   import random
   
   class MetricsHandler(BaseHTTPRequestHandler):
       def do_GET(self):
           self.send_response(200)
           self.send_header('Content-Type', 'text/plain')
           self.end_headers()
           metric = f"# HELP test_metric A test metric\n# TYPE test_metric gauge\ntest_metric{{label=\"test\"}} {random.random() * 100}\n"
           self.wfile.write(metric.encode())
   
   HTTPServer(('', 8099), MetricsHandler).serve_forever()
   ```

2. **Configure Prometheus to scrape test metrics**
   ```yaml
   scrape_configs:
     - job_name: 'test'
       static_configs:
         - targets: ['localhost:8099']
   ```

3. **Set up alert rule for test metric**
   ```yaml
   groups:
   - name: test
     rules:
     - alert: TestMetricHigh
       expr: test_metric > 50
       for: 1m
       labels:
         severity: critical
       annotations:
         summary: "Test metric is high"
         description: "Test metric value is {{ $value }}"
   ```

4. **Create dashboard in Grafana**
   ```bash
   # Import dashboard via API
   curl -X POST -H "Authorization: Bearer admin:admin" -H "Content-Type: application/json" -d '{
     "dashboard": {
       "title": "Test Dashboard",
       "panels": [
         {
           "title": "Test Metric",
           "type": "graph",
           "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
           "targets": [{"expr": "test_metric", "legendFormat": ""}]
         }
       ]
     },
     "overwrite": true
   }' http://localhost:3000/api/dashboards/db | jq .
   ```

5. **Verify complete pipeline**
   - Check if metric is scraped by Prometheus:
     ```bash
     curl -s --data-urlencode 'query=test_metric' http://localhost:9090/api/v1/query | jq .
     ```
   - Check if alert fires when value > 50:
     ```bash
     curl -s http://localhost:9090/api/v1/alerts | jq .
     ```
   - Verify alert is received by AlertManager:
     ```bash
     curl -s http://localhost:9093/api/v1/alerts | jq .
     ```
   - Check if metric appears on Grafana dashboard

### System Resource Check

```bash
# Check CPU usage
top -bn1 | grep "Cpu(s)"

# Check memory usage
free -m

# Check disk space
df -h /var/lib/prometheus/ /var/lib/grafana/

# Check open file limits
ulimit -n
cat /proc/$(pgrep prometheus)/limits

# Check network connections
netstat -plunt | grep -E '9090|9093|3000'
```

### Backup and Recovery Test

```bash
# Backup Prometheus data
tar -cvzf prometheus-backup.tar.gz /var/lib/prometheus/data/

# Backup Grafana data
pg_dump -U grafana grafana > grafana-backup.sql  # For PostgreSQL
sqlite3 /var/lib/grafana/grafana.db .dump > grafana-backup.sql  # For SQLite

# Backup configuration files
tar -cvzf config-backup.tar.gz /etc/prometheus/ /etc/grafana/

# Test recovery in a separate environment or container
```

---

## Best Practices for Monitoring System Maintenance

1. **Regular updates**
   ```bash
   # Check versions
   prometheus --version
   grafana-server -v
   
   # Update via package manager
   sudo apt update
   sudo apt upgrade prometheus grafana
   
   # Or using Docker
   docker pull prom/prometheus:latest
   docker pull grafana/grafana:latest
   
   # Restart services after update
   sudo systemctl restart prometheus grafana-server
```

2. **Configuration management**
   ```bash
   # Store configs in version control
   git init /etc/prometheus/
   git -C /etc/prometheus/ add .
   git -C /etc/prometheus/ commit -m "Initial commit"
   
   # Test changes before applying
   promtool check config /etc/prometheus/prometheus.yml.new
   
   # Use diff to compare changes
   diff -u /etc/prometheus/prometheus.yml.old /etc/prometheus/prometheus.yml.new
   ```

3. **Performance tuning**
   ```bash
   # Optimize scrape intervals based on metric importance
   # Critical metrics: 10-30s
   # Standard metrics: 30-60s
   # Slow-changing metrics: 5m+
   
   # Use recording rules for complex queries
   # In prometheus.yml:
   rule_files:
     - 'recording_rules.yml'
   
   # In recording_rules.yml:
   groups:
   - name: cpu
     interval: 1m
     rules:
     - record: instance:node_cpu:avg_rate5m
       expr: avg by(instance) (rate(node_cpu_seconds_total{mode!="idle"}[5m]))
   ```

4. **High availability setup**
   ```bash
   # Run multiple Prometheus instances
   # In prometheus1.yml:
   global:
     external_labels:
       replica: replica1
   
   # Use Thanos or Cortex for high-availability
   # Example Thanos sidecar:
   docker run -d --name thanos-sidecar \
     -v /path/to/prometheus:/prometheus \
     quay.io/thanos/thanos:latest \
     sidecar \
     --prometheus.url=http://prometheus:9090 \
     --tsdb.path=/prometheus
   ```

## Troubleshooting Recipes for Common Scenarios

### Scenario: High Memory Usage in Prometheus

**Symptoms:**
- Prometheus service consuming excessive memory
- Possible OOM (Out of Memory) kills
- Slow query performance

**Diagnosis Commands:**
```bash
# Check current memory usage
ps aux | grep prometheus | awk '{print $6/1024 " MB"}'

# Check memory-related metrics
curl -s http://localhost:9090/metrics | grep process_resident_memory_bytes

# Check number of time series
curl -s http://localhost:9090/api/v1/status/tsdb | jq '.data.seriesCountByMetricName | to_entries | sort_by(.value) | reverse | .[0:10]'

# Check cardinality of specific metrics
curl -s --data-urlencode 'query=count({__name__=~".+"}) by (__name__)' http://localhost:9090/api/v1/query | jq '.data.result | sort_by(.value[1]) | reverse | .[0:20]'
```

**Resolution Steps:**
1. **Identify high-cardinality metrics:**
   ```bash
   # Find metrics with too many labels
   curl -s --data-urlencode 'query=count by (__name__, job)({__name__!=""})' http://localhost:9090/api/v1/query | jq '.data.result | sort_by(.value[1]) | reverse | .[0:20]'
   ```

2. **Apply relabeling to reduce cardinality:**
   ```yaml
   # In prometheus.yml
   scrape_configs:
     - job_name: 'high_cardinality_job'
       relabel_configs:
         - source_labels: [high_cardinality_label]
           action: replace
           target_label: high_cardinality_label
           regex: '(.*)'
           replacement: 'grouped_value'
   ```

3. **Increase memory limits:**
   ```bash
   # For systemd service
   sudo systemctl edit prometheus
   # Add:
   [Service]
   LimitNOFILE=65536
   LimitNPROC=65536
   MemoryLimit=8G
   
   # For Docker
   docker run -d --name prometheus \
     --memory="8g" \
     prom/prometheus:latest
   ```

4. **Use query timeouts to prevent resource exhaustion:**
   ```yaml
   # In prometheus.yml
   global:
     query_log_file: /var/log/prometheus/query.log
     
   web:
     enable_admin_api: true
     enable_lifecycle: true
   ```
   
   ```bash
   # Set query timeout header when querying
   curl -H "X-Prometheus-Query-Timeout: 30s" -g 'http://localhost:9090/api/v1/query?query=...'
   ```

### Scenario: Missing Data in Grafana Dashboards

**Symptoms:**
- Panels showing "No data" in Grafana
- Incomplete graphs with gaps
- Alerts not firing despite conditions being met

**Diagnosis Commands:**
```bash
# Check if Prometheus has the data
curl -s --data-urlencode 'query=up' http://prometheus:9090/api/v1/query | jq .

# Check specific metric existence
curl -s --data-urlencode 'query=node_cpu_seconds_total' http://prometheus:9090/api/v1/query | jq '.data.result | length'

# Check target scraping status
curl -s http://prometheus:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health=="down")'

# Verify datasource health in Grafana
curl -s -H "Authorization: Bearer admin:password" http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=up | jq .
```

**Resolution Steps:**
1. **Fix Prometheus scrape issues:**
   ```bash
   # Check for scrape errors
   curl -s http://prometheus:9090/metrics | grep "scrape_samples_scraped"
   
   # Verify target is properly discovered
   curl -s http://prometheus:9090/api/v1/targets | jq '.data.activeTargets[] | select(.labels.instance=="problematic-target:9100")'
   ```

2. **Check time synchronization:**
   ```bash
   # Verify NTP is working
   timedatectl status
   
   # Install and set up NTP if needed
   sudo apt install chrony
   sudo systemctl enable --now chronyd
   chronyc tracking
   ```

3. **Validate Grafana datasource configuration:**
   ```bash
   # Check datasource settings
   curl -s -H "Authorization: Bearer admin:password" http://localhost:3000/api/datasources/1 | jq .
   
   # Update datasource if needed
   curl -X PUT -H "Authorization: Bearer admin:password" -H "Content-Type: application/json" -d '{
     "name": "Prometheus",
     "type": "prometheus",
     "url": "http://prometheus:9090",
     "access": "proxy",
     "basicAuth": false
   }' http://localhost:3000/api/datasources/1
   ```

4. **Fix dashboard query issues:**
   ```bash
   # Edit panel JSON directly
   curl -s -H "Authorization: Bearer admin:password" http://localhost:3000/api/dashboards/uid/dashboard-uid | jq '.dashboard.panels[0].targets[0].expr = "up"' > updated-dashboard.json
   
   curl -X POST -H "Authorization: Bearer admin:password" -H "Content-Type: application/json" -d @updated-dashboard.json http://localhost:3000/api/dashboards/db
   ```

### Scenario: Alert Notification Failures

**Symptoms:**
- Alerts triggering but notifications not being sent
- Missing alerts in external systems (Email, Slack, PagerDuty)
- Error messages in AlertManager logs

**Diagnosis Commands:**
```bash
# Check AlertManager configuration
amtool check-config /etc/alertmanager/alertmanager.yml

# View active alerts in AlertManager
curl -s http://localhost:9093/api/v1/alerts | jq .

# Check AlertManager status
curl -s http://localhost:9093/api/v1/status | jq .

# View silences (might be blocking notifications)
curl -s http://localhost:9093/api/v1/silences | jq .
```

**Resolution Steps:**
1. **Fix AlertManager configuration:**
   ```bash
   # Check syntax and structure
   amtool check-config /etc/alertmanager/alertmanager.yml
   
   # Reload configuration
   curl -X POST http://localhost:9093/-/reload
   ```

2. **Test notification channels directly:**
   ```bash
   # Test email
   echo "Subject: Test Alert Email" | sendmail -v recipient@example.com
   
   # Test Slack webhook
   curl -X POST -H 'Content-type: application/json' --data '{"text":"Test alert from AlertManager"}' https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
   
   # Test PagerDuty
   curl -H "Content-type: application/json" -X POST -d '{"routing_key":"YOUR_INTEGRATION_KEY","event_action":"trigger","payload":{"summary":"Test alert","source":"AlertManager test","severity":"critical"}}' "https://events.pagerduty.com/v2/enqueue"
   ```

3. **Check network connectivity for outbound traffic:**
   ```bash
   # Test SMTP connection
   nc -zv smtp.example.com 25
   
   # Test HTTPS connections
   curl -v https://hooks.slack.com
   
   # Check if proxy is needed
   env | grep -i proxy
   ```

4. **Review templating issues:**
   ```bash
   # Test template rendering
   amtool template test --template.file=/etc/alertmanager/templates/email.tmpl alert-test-data.json
   
   # Update template if needed
   cat > /etc/alertmanager/templates/email.tmpl << EOF
   {{ define "email.subject" }}[{{ .Status | toUpper }}] {{ .GroupLabels.alertname }}{{ end }}
   {{ define "email.body" }}
   Alert: {{ .GroupLabels.alertname }}
   Status: {{ .Status }}
   Severity: {{ .CommonLabels.severity }}
   Summary: {{ .CommonAnnotations.summary }}
   Description: {{ .CommonAnnotations.description }}
   {{ end }}
   EOF
   ```

## Advanced Troubleshooting Techniques

### Using pprof for Performance Profiling

```bash
# Enable pprof in Prometheus (if not already enabled)
# Add to prometheus.yml or command line:
web:
  enable_admin_api: true

# Capture CPU profile
curl -s http://localhost:9090/debug/pprof/profile?seconds=30 > prometheus-cpu.prof

# Capture heap profile
curl -s http://localhost:9090/debug/pprof/heap > prometheus-heap.prof

# Analyze with go tool
go tool pprof -http=:8080 prometheus-cpu.prof
go tool pprof -http=:8080 prometheus-heap.prof
```

### Analyzing TSDB Blocks

```bash
# Install Prometheus tools
go get github.com/prometheus/prometheus/cmd/promtool

# Analyze TSDB blocks
promtool tsdb analyze /var/lib/prometheus/data

# List blocks
ls -la /var/lib/prometheus/data/chunks_head

# Verify block integrity
promtool tsdb verify /var/lib/prometheus/data
```

### Debugging with Trace Logs

```bash
# Enable trace logging for Prometheus
# Add to systemd unit or command line:
--log.level=debug

# Filter logs for specific components
journalctl -u prometheus -f | grep "tsdb"
journalctl -u prometheus -f | grep "scrape"

# Enable query logging
# Add to prometheus.yml:
global:
  query_log_file: /var/log/prometheus/query.log

# Analyze slow queries
grep -i "slow query" /var/log/prometheus/query.log
```

## Preventive Maintenance Checklist

Regular maintenance ensures your monitoring system remains healthy and effective. Use this checklist as part of your routine maintenance:

### Weekly Checks

1. **Review storage usage trends:**
   ```bash
   # Check disk usage growth
   df -h /var/lib/prometheus
   
   # Analyze TSDB stats
   curl -s http://localhost:9090/api/v1/status/tsdb | jq .
   ```

2. **Verify target scraping health:**
   ```bash
   # Check for dropped targets
   curl -s 'http://localhost:9090/api/v1/targets?state=down' | jq .
   
   # Check scrape interval compliance
   curl -s --data-urlencode 'query=scrape_interval_seconds - (time() - scrape_time_seconds)' http://localhost:9090/api/v1/query | jq .
   ```

3. **Test alerting pipeline:**
   ```bash
   # Fire test alert
   curl -H "Content-Type: application/json" -d '[{"labels":{"alertname":"TestAlert","severity":"test"}}]' http://localhost:9093/api/v1/alerts
   
   # Verify receipt in notification channels
   ```

### Monthly Checks

1. **Update Prometheus and Grafana:**
   ```bash
   # Check for updates
   apt list --upgradable | grep -E 'prometheus|grafana'
   
   # Apply updates in test environment first
   ```

2. **Review and optimize high-cardinality metrics:**
   ```bash
   # Find top cardinality metrics
   curl -s --data-urlencode 'query=count({__name__=~".+"}) by (__name__)' http://localhost:9090/api/v1/query | jq '.data.result | sort_by(.value[1]) | reverse | .[0:20]'
   
   # Add relabeling or dropping as needed
   ```

3. **Back up critical configurations and data:**
   ```bash
   # Backup Prometheus config
   tar -czf prometheus-config-$(date +%Y%m%d).tar.gz /etc/prometheus/
   
   # Backup Grafana dashboards
   curl -s -H "Authorization: Bearer admin:password" http://localhost:3000/api/dashboards/home | jq . > grafana-dashboards-$(date +%Y%m%d).json
   ```

### Quarterly Checks

1. **Review retention policies and storage needs:**
   ```bash
   # Adjust retention based on growth
   # In prometheus.yml:
   storage:
     tsdb:
       retention.time: 30d
       retention.size: 100GB
   ```

2. **Perform full system health assessment:**
   ```bash
   # Run comprehensive checks
   # - Storage performance
   # - Memory usage
   # - Query performance
   # - Alerting reliability
   ```

3. **Update documentation and runbooks:**
   ```bash
   # Document recent changes
   # Update playbooks for new alert types
   # Review emergency procedures
   ```

By maintaining a comprehensive troubleshooting guide and following these preventive maintenance steps, you'll ensure your Prometheus and Grafana monitoring system remains reliable, performant, and effective at detecting issues across your infrastructure.